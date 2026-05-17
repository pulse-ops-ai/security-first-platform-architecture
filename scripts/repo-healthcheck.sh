#!/usr/bin/env bash
# repo-healthcheck.sh
#
# Validates a repository against `standards/repo-contract.md`. Replaces
# the prior procedural skill description with an executable check, so
# the contract is enforced rather than narrated.
#
# Auto-detects mode based on a sentinel file:
#   - architecture-repo mode (sentinel `standards/repo-contract.md`
#     present): this repo IS the contract; skip consumer-only checks
#     (security-first-adoption.md presence + adapter-declaration
#     consistency) but still validate the Universal Floor and any
#     present adapters route to AGENTS.md.
#   - consumer mode (sentinel absent): run the full check.
#
# Usage:
#   bash scripts/repo-healthcheck.sh                    # check $PWD
#   bash scripts/repo-healthcheck.sh /path/to/repo      # check given path
#
# Exit codes:
#   0  PASS — no errors (warnings allowed)
#   1  FAIL — one or more errors
#   2  invocation error

set -uo pipefail

# ---------- Setup ----------

TARGET="${1:-.}"
if [[ ! -d "$TARGET" ]]; then
  echo "ERROR: target is not a directory: $TARGET" >&2
  exit 2
fi
cd "$TARGET" || exit 2

# Sentinel: the architecture repo ships standards/repo-contract.md.
# Consuming repos reference it but don't ship their own copy.
IS_ARCHITECTURE_REPO=0
if [[ -f standards/repo-contract.md ]]; then
  IS_ARCHITECTURE_REPO=1
fi

ERR=0
WARN=0

err() { echo "[ERROR]   $*" >&2; ERR=$((ERR + 1)); }
warn() { echo "[WARN]    $*" >&2; WARN=$((WARN + 1)); }
ok()  { echo "[OK]      $*"; }
info() { echo "[INFO]    $*"; }

# ---------- YAML extractors ----------
#
# These are deliberate-bash, not a full YAML parser. They handle the
# subset of YAML that templates/consuming-repo/security-first-adoption.md
# uses: top-level scalars, comment-suffixed scalars, simple nested maps
# with indented children, and empty lists (`key: []`). They do NOT
# handle multi-line strings, anchors, or flow-style maps.

# Extract the YAML frontmatter (between the first two `---` lines).
extract_frontmatter() {
  local file="$1"
  awk 'NR==1 && $0=="---" { in_fm=1; next }
       in_fm==1 && $0=="---" { exit }
       in_fm==1 { print }' "$file"
}

# Extract a top-level scalar value by key. Strips trailing comments.
# Empty string if key is absent or has only a comment.
fm_scalar() {
  local fm="$1" key="$2"
  echo "$fm" | awk -v k="$key" '
    $0 ~ "^"k":" {
      sub("^"k":[[:space:]]*", "")
      sub("[[:space:]]*#.*$", "")
      gsub("^[[:space:]]+|[[:space:]]+$", "")
      print
      exit
    }
  '
}

# Extract a nested-map child value by parent+child key.
# Parent is at indent 0; children at deeper indent until the next
# indent-0 line.
fm_nested() {
  local fm="$1" parent="$2" child="$3"
  echo "$fm" | awk -v p="$parent" -v c="$child" '
    $0 ~ "^"p":" { in_block=1; next }
    in_block && /^[^[:space:]#]/ { exit }
    in_block && $0 ~ "^[[:space:]]+"c":" {
      sub("^[[:space:]]+"c":[[:space:]]*", "")
      sub("[[:space:]]*#.*$", "")
      gsub("^[[:space:]]+|[[:space:]]+$", "")
      print
      exit
    }
  '
}

# Check that a top-level key exists in the frontmatter (regardless of value).
fm_key_present() {
  local fm="$1" key="$2"
  echo "$fm" | grep -qE "^${key}:"
}

# ---------- Universal Floor (both modes) ----------

echo "== Universal Floor =="

for f in README.md AGENTS.md LICENSE; do
  if [[ -f "$f" ]]; then ok "$f present"; else err "MISSING root file: $f"; fi
done

if [[ ! -d docs ]]; then
  err "MISSING directory: docs/"
else
  ok "docs/ present"
fi

if [[ ! -f docs/INDEX.md ]]; then
  err "MISSING docs/INDEX.md"
else
  ok "docs/INDEX.md present"
fi

# ---------- security-first-adoption.md (consumer mode only) ----------

if [[ $IS_ARCHITECTURE_REPO -eq 1 ]]; then
  info "architecture repo detected (standards/repo-contract.md present); skipping security-first-adoption.md check"
  ADOPTION_PRESENT=0
else
  if [[ -f security-first-adoption.md ]]; then
    ok "security-first-adoption.md present"
    ADOPTION_PRESENT=1
  else
    err "MISSING security-first-adoption.md (required for consuming repos per repo-contract.md Universal Floor)"
    ADOPTION_PRESENT=0
  fi
fi

# ---------- Adoption record frontmatter validation (consumer mode, when present) ----------

if [[ $ADOPTION_PRESENT -eq 1 ]]; then
  echo
  echo "== security-first-adoption.md frontmatter =="

  FM="$(extract_frontmatter security-first-adoption.md)"
  if [[ -z "$FM" ]]; then
    err "security-first-adoption.md has no YAML frontmatter"
  else
    # Required scalars
    for key in adopting_repo architecture_repo architecture_ref architecture_ref_kind \
               adoption_date review_cadence owner profile; do
      val="$(fm_scalar "$FM" "$key")"
      if [[ -z "$val" ]]; then
        err "frontmatter field '$key' is empty (or comment-only)"
      else
        ok "frontmatter field '$key' = $val"
      fi
    done

    # Required nested: adopted_control_layers (all 8 layers)
    for layer in l1_network_reachability l2_edge_gateway l3_identity l4_authorization \
                 l5_operational_guardrails l6_orchestrator_bff l7_service_enforcement \
                 l8_semantic_agent; do
      val="$(fm_nested "$FM" "adopted_control_layers" "$layer")"
      if [[ -z "$val" ]]; then
        err "adopted_control_layers.$layer is empty"
      elif [[ "$val" != "implemented" && "$val" != "consumed" && "$val" != "n/a" ]]; then
        err "adopted_control_layers.$layer = '$val' (must be 'implemented' | 'consumed' | 'n/a')"
      else
        ok "adopted_control_layers.$layer = $val"
      fi
    done

    # Required nested: agent_adapters_in_use (4 named adapters)
    for adapter in claude_code codex github_copilot cursor; do
      val="$(fm_nested "$FM" "agent_adapters_in_use" "$adapter")"
      if [[ -z "$val" ]]; then
        err "agent_adapters_in_use.$adapter is empty (must be 'true' or 'false')"
      elif [[ "$val" != "true" && "$val" != "false" ]]; then
        err "agent_adapters_in_use.$adapter = '$val' (must be 'true' or 'false')"
      else
        ok "agent_adapters_in_use.$adapter = $val"
      fi
    done

    # Required list keys (presence only; empty list `[]` is acceptable)
    for key in deviations pending_openspec_changes cross_repo_dependencies; do
      if fm_key_present "$FM" "$key"; then
        ok "frontmatter key '$key' present"
      else
        err "frontmatter key '$key' is missing (use '[]' if empty)"
      fi
    done
  fi
fi

# ---------- Conditional Floor ----------

echo
echo "== Conditional Floor =="

if [[ -d openspec ]]; then
  if [[ -f openspec/README.md ]]; then
    ok "openspec/README.md present (openspec/ exists)"
  else
    err "openspec/ exists but openspec/README.md is missing"
  fi
fi

if [[ -d .github && -d .github/workflows ]]; then
  ok ".github/workflows/ present"
fi

if [[ -d .agents/skills ]]; then
  if [[ -f .agents/skills/INDEX.md ]]; then
    ok ".agents/skills/INDEX.md present (.agents/skills/ exists)"
  else
    err ".agents/skills/ exists but .agents/skills/INDEX.md is missing"
  fi
fi

# ---------- Vendor-Specific Adapters ----------

echo
echo "== Vendor-Specific Adapters =="

# Map adapter -> declared value (from adoption record, if present)
declare -A DECLARED=()
if [[ $ADOPTION_PRESENT -eq 1 ]]; then
  for adapter in claude_code codex github_copilot cursor; do
    DECLARED[$adapter]="$(fm_nested "$FM" "agent_adapters_in_use" "$adapter")"
  done
fi

# claude_code: when true, BOTH CLAUDE.md AND .claude/ must be present.
#              when false, neither should be present (mismatch = ERROR).
claude_decl="${DECLARED[claude_code]:-}"
claude_md_present=$([[ -f CLAUDE.md ]] && echo "yes" || echo "no")
claude_dir_present=$([[ -d .claude ]] && echo "yes" || echo "no")

if [[ $IS_ARCHITECTURE_REPO -eq 1 ]]; then
  # Architecture repo: skip declaration-consistency check; only verify
  # routing for any present adapter files.
  :
elif [[ "$claude_decl" == "true" ]]; then
  if [[ "$claude_md_present" == "yes" ]]; then
    ok "CLAUDE.md present (claude_code: true)"
  else
    err "MISSING CLAUDE.md (claude_code: true)"
  fi
  if [[ "$claude_dir_present" == "yes" ]]; then
    ok ".claude/ present (claude_code: true)"
  else
    err "MISSING .claude/ (claude_code: true)"
  fi
elif [[ "$claude_decl" == "false" ]]; then
  if [[ "$claude_md_present" == "yes" || "$claude_dir_present" == "yes" ]]; then
    err "Adapter mismatch: claude_code is 'false' but CLAUDE.md or .claude/ is present in the tree"
  else
    ok "claude_code: false and no CLAUDE.md/.claude/ present"
  fi
fi

# Routing check: if CLAUDE.md exists, it must reference AGENTS.md (both modes).
if [[ -f CLAUDE.md ]]; then
  if grep -q "AGENTS\.md" CLAUDE.md; then
    ok "CLAUDE.md routes to AGENTS.md"
  else
    err "CLAUDE.md does not reference AGENTS.md (adapter must route, not duplicate)"
  fi
fi

# codex
codex_decl="${DECLARED[codex]:-}"
codex_dir_present=$([[ -d .codex ]] && echo "yes" || echo "no")
if [[ $IS_ARCHITECTURE_REPO -eq 1 ]]; then
  :
elif [[ "$codex_decl" == "true" ]]; then
  if [[ "$codex_dir_present" == "yes" ]]; then
    ok ".codex/ present (codex: true)"
  else
    err "MISSING .codex/ (codex: true)"
  fi
elif [[ "$codex_decl" == "false" ]]; then
  if [[ "$codex_dir_present" == "yes" ]]; then
    err "Adapter mismatch: codex is 'false' but .codex/ is present in the tree"
  else
    ok "codex: false and no .codex/ present"
  fi
fi

# github_copilot
copilot_decl="${DECLARED[github_copilot]:-}"
copilot_file_present=$([[ -f .github/copilot-instructions.md ]] && echo "yes" || echo "no")
if [[ $IS_ARCHITECTURE_REPO -eq 1 ]]; then
  :
elif [[ "$copilot_decl" == "true" ]]; then
  if [[ "$copilot_file_present" == "yes" ]]; then
    ok ".github/copilot-instructions.md present (github_copilot: true)"
  else
    err "MISSING .github/copilot-instructions.md (github_copilot: true)"
  fi
elif [[ "$copilot_decl" == "false" ]]; then
  if [[ "$copilot_file_present" == "yes" ]]; then
    err "Adapter mismatch: github_copilot is 'false' but .github/copilot-instructions.md is present"
  else
    ok "github_copilot: false and no .github/copilot-instructions.md present"
  fi
fi

# Routing check: if .github/copilot-instructions.md exists, it must reference AGENTS.md.
if [[ -f .github/copilot-instructions.md ]]; then
  if grep -q "AGENTS\.md" .github/copilot-instructions.md; then
    ok ".github/copilot-instructions.md routes to AGENTS.md"
  else
    err ".github/copilot-instructions.md does not reference AGENTS.md"
  fi
fi

# cursor
cursor_decl="${DECLARED[cursor]:-}"
cursor_file_present=$([[ -f .cursorrules ]] && echo "yes" || echo "no")
if [[ $IS_ARCHITECTURE_REPO -eq 1 ]]; then
  :
elif [[ "$cursor_decl" == "true" ]]; then
  if [[ "$cursor_file_present" == "yes" ]]; then
    ok ".cursorrules present (cursor: true)"
  else
    err "MISSING .cursorrules (cursor: true)"
  fi
elif [[ "$cursor_decl" == "false" ]]; then
  if [[ "$cursor_file_present" == "yes" ]]; then
    err "Adapter mismatch: cursor is 'false' but .cursorrules is present"
  else
    ok "cursor: false and no .cursorrules present"
  fi
fi

# ---------- AGENTS.md content ----------

echo
echo "== AGENTS.md content =="

if [[ -f AGENTS.md ]]; then
  if [[ ! -s AGENTS.md ]]; then
    err "AGENTS.md is empty"
  else
    ok "AGENTS.md is non-empty"
    if ! grep -qi "architecture" AGENTS.md; then
      warn "AGENTS.md does not mention 'architecture' (expected at least one reference to the architecture entrypoint)"
    fi
    if ! grep -qiE "team-os|teamos" AGENTS.md; then
      warn "AGENTS.md does not mention 'team-os' (expected at least one reference to the team-os entrypoint)"
    fi
  fi
fi

# ---------- Summary ----------

echo
echo "== Summary =="
if [[ $IS_ARCHITECTURE_REPO -eq 1 ]]; then
  echo "mode:     architecture-repo (consumer-only checks skipped)"
else
  echo "mode:     consumer-repo"
fi
echo "errors:   $ERR"
echo "warnings: $WARN"

if [[ $ERR -gt 0 ]]; then
  echo "repo-healthcheck: FAIL"
  exit 1
fi
echo "repo-healthcheck: PASS"
