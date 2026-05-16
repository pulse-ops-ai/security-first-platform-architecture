#!/usr/bin/env bash
# sync-agent-skills.sh
#
# Canonical ↔ vendor-shim drift layer for agent skills.
#
# Canonical home: .agents/skills/<name>/SKILL.md
# Vendor shims:   .claude/skills/<name>/SKILL.md
#                 .codex/skills/<name>/SKILL.md
# Claude slash commands: .claude/commands/<name>.md
#
# scripts/validate-skills.sh already enforces the canonical SKILL.md
# structure (frontmatter, Procedure, Output). This script enforces the
# relationship between canonical skills and their vendor shims/commands:
#
#   - shims must point to a canonical skill that exists
#   - shim `name:` must match canonical `name:` and the shim directory
#   - shims must have a description
#   - shims must include `## Procedure` OR delegate to canonical
#   - shims must include `## Output` OR carry an opt-out marker
#   - orphan shims/commands fail
#   - missing optional shims/commands warn (with opt-out markers honored)
#
# See standards/agent-instructions-standard.md for the full contract.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

CANONICAL_DIR=".agents/skills"
CLAUDE_SHIM_DIR=".claude/skills"
CODEX_SHIM_DIR=".codex/skills"
CLAUDE_COMMANDS_DIR=".claude/commands"

mode=""
bootstrap_name=""
bootstrap_vendor=""
force=0

# ---------- Usage ----------

usage() {
  cat <<'EOF'
Usage: sync-agent-skills.sh <mode> [options]

Modes:
  --check
      Validate all shims and Claude slash commands against canonical
      .agents/skills. Print a coverage report. Exit non-zero only on
      drift (invalid shim, orphan, name mismatch). Warnings do not fail.

  --bootstrap <skill-name> --vendor claude|codex [--force]
      Create a starter shim from .agents/skills/<skill-name>/SKILL.md.
      For Claude:  writes .claude/skills/<skill-name>/SKILL.md and injects
                   `argument-hint:` into the frontmatter if absent.
      For Codex:   writes .codex/skills/<skill-name>/SKILL.md (requires
                   .codex/skills/ to already exist in the repo).
      Refuses to overwrite an existing shim unless --force is supplied.

  --help, -h
      Show this message.

Opt-out markers (placed anywhere in canonical .agents/skills/<name>/SKILL.md):
  no-shim: claude        — this canonical skill does not need a Claude shim
  no-shim: codex         — this canonical skill does not need a Codex shim
  no-command: claude     — this canonical skill does not need a /<name> command

Opt-out marker (placed anywhere in .claude/commands/<name>.md):
  command-only: true     — this slash command intentionally has no canonical skill

These markers may appear as HTML comments, code-fenced lines, frontmatter
fields, or plain lines; the script matches the substring.

Examples:
  bash scripts/sync-agent-skills.sh --check
  bash scripts/sync-agent-skills.sh --bootstrap pull-from-notion --vendor claude
  bash scripts/sync-agent-skills.sh --bootstrap repo-healthcheck --vendor codex --force
EOF
}

# ---------- Argument parsing ----------

if [[ $# -eq 0 ]]; then
  usage
  exit 2
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      mode="check"
      shift
      ;;
    --bootstrap)
      mode="bootstrap"
      bootstrap_name="${2:-}"
      if [[ -z "$bootstrap_name" || "$bootstrap_name" == --* ]]; then
        echo "ERROR: --bootstrap requires a skill name" >&2
        exit 2
      fi
      shift 2
      ;;
    --vendor)
      bootstrap_vendor="${2:-}"
      if [[ -z "$bootstrap_vendor" || "$bootstrap_vendor" == --* ]]; then
        echo "ERROR: --vendor requires a value (claude|codex)" >&2
        exit 2
      fi
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

# ---------- Helpers ----------

# Extract YAML frontmatter (text between the first two --- delimiters).
read_frontmatter() {
  local file="$1"
  awk 'NR==1 && $0=="---" { in_fm=1; next }
       in_fm==1 && $0=="---" { in_fm=2; exit }
       in_fm==1 { print }' "$file"
}

# Extract a scalar frontmatter value by key (first match; trims quotes/space).
fm_value() {
  local file="$1" key="$2"
  read_frontmatter "$file" | awk -v k="$key" '
    $0 ~ "^"k":" {
      sub("^"k":[[:space:]]*", "")
      gsub("^[\"'\'']|[\"'\'']$", "")
      print
      exit
    }
  '
}

# Does file contain the given substring anywhere?
has_marker() {
  local file="$1" marker="$2"
  grep -Fq -- "$marker" "$file" 2>/dev/null
}

# Does file contain the given section heading?
has_section() {
  local file="$1" section="$2"
  grep -Fq -- "$section" "$file" 2>/dev/null
}

# Heuristic: is .codex/skills/ in active use? True iff at least one
# <name>/SKILL.md exists under .codex/skills/.
codex_in_use() {
  [[ -d "$CODEX_SHIM_DIR" ]] || return 1
  local d
  while IFS= read -r d; do
    [[ -f "$d/SKILL.md" ]] && return 0
  done < <(find "$CODEX_SHIM_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  return 1
}

# ---------- Counters ----------

ERR=0
WARN=0
CANON_COUNT=0
CLAUDE_SHIM_COUNT=0
CODEX_SHIM_COUNT=0
CLAUDE_CMD_COUNT=0

err() {
  echo "ERROR: $*" >&2
  ERR=$((ERR + 1))
}

warn() {
  echo "WARN:  $*" >&2
  WARN=$((WARN + 1))
}

# Validate the frontmatter of a SKILL.md file.
# Args: <file> <expected-name> <kind-label>
validate_shim_frontmatter() {
  local file="$1" expected_name="$2" kind="$3"
  local name desc

  if [[ "$(head -n1 "$file")" != "---" ]]; then
    err "$kind: $file: missing YAML frontmatter (must start with '---')"
    return
  fi

  name="$(fm_value "$file" "name")"
  desc="$(fm_value "$file" "description")"

  if [[ -z "$name" ]]; then
    err "$kind: $file: missing frontmatter 'name:'"
  elif [[ "$name" != "$expected_name" ]]; then
    err "$kind: $file: frontmatter name='$name' does not match expected '$expected_name'"
  fi

  if [[ -z "$desc" ]]; then
    err "$kind: $file: missing frontmatter 'description:'"
  fi
}

# Validate a vendor shim body (loose: requires Procedure or canonical reference;
# requires Output or an output-not-applicable marker).
validate_shim_body() {
  local file="$1" canon_file="$2" canon_name="$3" kind="$4"

  if ! has_section "$file" "## Procedure"; then
    if grep -Fq -- "$canon_file" "$file" 2>/dev/null \
       || grep -Fq -- ".agents/skills/$canon_name" "$file" 2>/dev/null; then
      : # delegates to canonical — OK
    else
      err "$kind: $file: missing '## Procedure' and no reference to canonical $canon_file"
    fi
  fi

  if ! has_section "$file" "## Output"; then
    if ! has_marker "$file" "output-not-applicable:"; then
      err "$kind: $file: missing '## Output' and no 'output-not-applicable:' marker"
    fi
  fi
}

# ---------- Check mode ----------

check_mode() {
  if [[ ! -d "$CANONICAL_DIR" ]]; then
    err "$CANONICAL_DIR/ directory not found"
    print_summary
    exit 1
  fi

  local codex_required=0
  if codex_in_use; then
    codex_required=1
  fi

  echo "== Canonical skills under $CANONICAL_DIR =="
  if [[ $codex_required -eq 1 ]]; then
    echo "(.codex/skills/ is in active use — missing Codex shims will warn)"
  else
    echo "(.codex/skills/ has no populated shims — Codex coverage is advisory only)"
  fi
  echo

  local SKILL_DIRS=()
  while IFS= read -r d; do
    SKILL_DIRS+=("$d")
  done < <(find "$CANONICAL_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

  local dir name canon_file
  for dir in "${SKILL_DIRS[@]}"; do
    name="$(basename "$dir")"
    canon_file="$dir/SKILL.md"
    CANON_COUNT=$((CANON_COUNT + 1))

    echo "  $name"

    if [[ ! -f "$canon_file" ]]; then
      err "$canon_file missing"
      continue
    fi

    # Canonical structural sanity (the canonical-skills validator does the
    # full check; we only enforce the frontmatter contract used by sync.)
    if [[ "$(head -n1 "$canon_file")" != "---" ]]; then
      err "canonical: $canon_file: missing YAML frontmatter"
      continue
    fi
    local canon_name canon_desc
    canon_name="$(fm_value "$canon_file" "name")"
    canon_desc="$(fm_value "$canon_file" "description")"
    if [[ -z "$canon_name" ]]; then
      err "canonical: $canon_file: missing frontmatter 'name:'"
      continue
    fi
    if [[ "$canon_name" != "$name" ]]; then
      err "canonical: $canon_file: frontmatter name='$canon_name' does not match directory '$name'"
      continue
    fi
    if [[ -z "$canon_desc" ]]; then
      err "canonical: $canon_file: missing frontmatter 'description:'"
    fi

    # ----- Claude shim -----
    local claude_file="$CLAUDE_SHIM_DIR/$name/SKILL.md"
    if [[ -f "$claude_file" ]]; then
      CLAUDE_SHIM_COUNT=$((CLAUDE_SHIM_COUNT + 1))
      validate_shim_frontmatter "$claude_file" "$name" "claude-shim"
      validate_shim_body "$claude_file" "$canon_file" "$name" "claude-shim"
      echo "    [OK] claude shim present ($claude_file)"
    else
      if has_marker "$canon_file" "no-shim: claude"; then
        echo "    [OK] no Claude shim (opted out via 'no-shim: claude')"
      else
        warn "no Claude shim at $claude_file (canonical does not opt out)"
      fi
    fi

    # ----- Codex shim -----
    local codex_file="$CODEX_SHIM_DIR/$name/SKILL.md"
    if [[ -f "$codex_file" ]]; then
      CODEX_SHIM_COUNT=$((CODEX_SHIM_COUNT + 1))
      validate_shim_frontmatter "$codex_file" "$name" "codex-shim"
      validate_shim_body "$codex_file" "$canon_file" "$name" "codex-shim"
      echo "    [OK] codex shim present ($codex_file)"
    else
      if has_marker "$canon_file" "no-shim: codex"; then
        echo "    [OK] no Codex shim (opted out via 'no-shim: codex')"
      elif [[ $codex_required -eq 1 ]]; then
        warn "no Codex shim at $codex_file (canonical does not opt out, and .codex/skills is in use)"
      fi
      # else: silent — Codex shims not in active use repo-wide
    fi

    # ----- Claude slash command -----
    local cmd_file="$CLAUDE_COMMANDS_DIR/$name.md"
    if [[ -f "$cmd_file" ]]; then
      CLAUDE_CMD_COUNT=$((CLAUDE_CMD_COUNT + 1))
      echo "    [OK] claude command present ($cmd_file)"
    else
      if has_marker "$canon_file" "no-command: claude"; then
        echo "    [OK] no Claude command (opted out via 'no-command: claude')"
      else
        warn "no Claude command at $cmd_file (canonical does not opt out)"
      fi
    fi
  done

  echo
  echo "== Orphaned shims and commands =="

  # Orphaned Claude shims.
  if [[ -d "$CLAUDE_SHIM_DIR" ]]; then
    local d n
    while IFS= read -r d; do
      n="$(basename "$d")"
      if [[ ! -d "$CANONICAL_DIR/$n" ]]; then
        err "orphan claude shim: $d/SKILL.md has no canonical $CANONICAL_DIR/$n/SKILL.md"
      fi
    done < <(find "$CLAUDE_SHIM_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  fi

  # Orphaned Codex shims.
  if [[ -d "$CODEX_SHIM_DIR" ]]; then
    local d n
    while IFS= read -r d; do
      n="$(basename "$d")"
      if [[ ! -d "$CANONICAL_DIR/$n" ]]; then
        err "orphan codex shim: $d/SKILL.md has no canonical $CANONICAL_DIR/$n/SKILL.md"
      fi
    done < <(find "$CODEX_SHIM_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  fi

  # Orphaned Claude commands.
  if [[ -d "$CLAUDE_COMMANDS_DIR" ]]; then
    local f base
    while IFS= read -r f; do
      base="$(basename "$f" .md)"
      [[ "$base" == "README" ]] && continue
      if [[ ! -d "$CANONICAL_DIR/$base" ]]; then
        if has_marker "$f" "command-only: true"; then
          echo "  [OK] orphan-by-design: $f (marked 'command-only: true')"
        else
          err "orphan Claude command: $f has no canonical $CANONICAL_DIR/$base/SKILL.md (and no 'command-only: true' marker)"
        fi
      fi
    done < <(find "$CLAUDE_COMMANDS_DIR" -mindepth 1 -maxdepth 1 -type f -name '*.md' 2>/dev/null)
  fi

  print_summary

  if [[ $ERR -gt 0 ]]; then
    echo "sync-agent-skills (--check): FAIL"
    exit 1
  fi
  echo "sync-agent-skills (--check): PASS"
}

print_summary() {
  echo
  echo "== Summary =="
  echo "  canonical skills checked: $CANON_COUNT"
  echo "  Claude shims checked:     $CLAUDE_SHIM_COUNT"
  if codex_in_use; then
    echo "  Codex shims checked:      $CODEX_SHIM_COUNT"
  else
    echo "  Codex shims checked:      $CODEX_SHIM_COUNT (advisory; .codex/skills not in active use)"
  fi
  echo "  Claude commands checked:  $CLAUDE_CMD_COUNT"
  echo "  warnings: $WARN"
  echo "  errors:   $ERR"
}

# ---------- Bootstrap mode ----------

bootstrap_mode() {
  if [[ -z "$bootstrap_name" ]]; then
    echo "ERROR: bootstrap: missing skill name" >&2
    exit 2
  fi
  if [[ -z "$bootstrap_vendor" ]]; then
    echo "ERROR: bootstrap: missing --vendor (claude|codex)" >&2
    exit 2
  fi

  local canon_dir="$CANONICAL_DIR/$bootstrap_name"
  local canon_file="$canon_dir/SKILL.md"
  if [[ ! -f "$canon_file" ]]; then
    echo "ERROR: bootstrap: canonical skill not found: $canon_file" >&2
    exit 1
  fi

  local target_file
  case "$bootstrap_vendor" in
    claude)
      target_file="$CLAUDE_SHIM_DIR/$bootstrap_name/SKILL.md"
      ;;
    codex)
      if [[ ! -d "$CODEX_SHIM_DIR" ]]; then
        echo "ERROR: bootstrap: $CODEX_SHIM_DIR does not exist." >&2
        echo "       This repo does not currently use Codex shims." >&2
        echo "       Create $CODEX_SHIM_DIR/ first if you want to start using it." >&2
        exit 1
      fi
      target_file="$CODEX_SHIM_DIR/$bootstrap_name/SKILL.md"
      ;;
    *)
      echo "ERROR: bootstrap: unknown vendor '$bootstrap_vendor' (expected claude or codex)" >&2
      exit 2
      ;;
  esac

  if [[ -f "$target_file" && $force -ne 1 ]]; then
    echo "ERROR: bootstrap: target already exists (use --force to overwrite): $target_file" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target_file")"

  # Copy canonical content. For Claude, inject `argument-hint:` into the
  # frontmatter if not already present.
  if [[ "$bootstrap_vendor" == "claude" ]] && ! grep -q '^argument-hint:' "$canon_file"; then
    awk '
      NR==1 && $0=="---" { print; in_fm=1; next }
      in_fm==1 && $0=="---" {
        print "argument-hint: \"[arguments]\""
        print
        in_fm=2
        next
      }
      { print }
    ' "$canon_file" > "$target_file"
  else
    cp "$canon_file" "$target_file"
  fi

  # Append a traceability footer.
  cat >> "$target_file" <<EOF

<!-- Shim generated from $canon_file by scripts/sync-agent-skills.sh -->
<!-- Customize vendor-specific bits (argument hints, slash-command semantics, tool calls) here. -->
<!-- For procedure/output changes, edit the canonical first. -->
EOF

  echo "Created shim: $target_file"
}

# ---------- Dispatch ----------

case "$mode" in
  check)
    check_mode
    ;;
  bootstrap)
    bootstrap_mode
    ;;
  "")
    usage
    exit 2
    ;;
  *)
    echo "ERROR: unknown mode: $mode" >&2
    usage
    exit 2
    ;;
esac
