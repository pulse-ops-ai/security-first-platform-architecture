#!/usr/bin/env bash
# validate-skills.sh
#
# Validates the canonical skills directory .agents/skills/:
#   1. Every .agents/skills/<name>/ has a SKILL.md.
#   2. .agents/skills/INDEX.md references every skill directory.
#   3. Each SKILL.md begins with YAML frontmatter containing `name:` and
#      `description:`, and the body contains `## Procedure` and `## Output`.
#
# Adapter shims under .claude/skills/ and .codex/skills/ are not required
# to satisfy the full structure — the canonical .agents/skills/<name>/ is.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0

CANONICAL_DIR=".agents/skills"

if [[ ! -d "$CANONICAL_DIR" ]]; then
  echo "[MISSING] $CANONICAL_DIR/ directory"
  exit 1
fi

if [[ ! -f "$CANONICAL_DIR/INDEX.md" ]]; then
  echo "[MISSING] $CANONICAL_DIR/INDEX.md"
  fail=1
fi

echo "== Skill folders under $CANONICAL_DIR =="
mapfile -t SKILL_DIRS < <(find "$CANONICAL_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

REQUIRED_SECTIONS=(
  "## Procedure"
  "## Output"
)

for dir in "${SKILL_DIRS[@]}"; do
  name="$(basename "$dir")"
  skill_md="$dir/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    echo "[MISSING]   $skill_md"
    fail=1
    continue
  fi

  echo "  $name"
  echo "    [OK] SKILL.md present"

  # Frontmatter check: must start with --- and contain name:/description:.
  first_line="$(head -n 1 "$skill_md")"
  if [[ "$first_line" != "---" ]]; then
    echo "    [MISSING] YAML frontmatter (file must start with '---')"
    fail=1
  else
    fm="$(awk '/^---$/{c++; next} c==1{print} c>=2{exit}' "$skill_md")"
    if ! grep -q '^name:' <<<"$fm"; then
      echo "    [MISSING] frontmatter field 'name:'"
      fail=1
    else
      fm_name="$(grep '^name:' <<<"$fm" | head -n1 | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'" | tr -d '[:space:]')"
      if [[ "$fm_name" != "$name" ]]; then
        echo "    [MISMATCH] frontmatter name='$fm_name' does not match directory '$name'"
        fail=1
      else
        echo "    [OK] frontmatter name matches directory"
      fi
    fi
    if ! grep -q '^description:' <<<"$fm"; then
      echo "    [MISSING] frontmatter field 'description:'"
      fail=1
    else
      echo "    [OK] frontmatter description present"
    fi
  fi

  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF -- "$section" "$skill_md"; then
      echo "    [OK] $section"
    else
      echo "    [MISSING] section '$section'"
      fail=1
    fi
  done

  if grep -qF -- "$name" "$CANONICAL_DIR/INDEX.md" 2>/dev/null; then
    echo "    [OK] referenced from $CANONICAL_DIR/INDEX.md"
  else
    echo "    [UNLISTED] $name not referenced from $CANONICAL_DIR/INDEX.md"
    fail=1
  fi
done

echo
if [[ $fail -ne 0 ]]; then
  echo "validate-skills: FAIL"
  exit 1
fi
echo "validate-skills: PASS"
