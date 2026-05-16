#!/usr/bin/env bash
# validate-doc-indexes.sh
#
# Validates the documentation-index spine. For each directory containing
# an INDEX.md, three checks run:
#
#   [UNLISTED] — a sibling *.md file exists in the directory but is not
#                referenced by INDEX.md.
#   [BROKEN]   — INDEX.md links to a relative file that does not exist.
#   [ORPHAN]   — a subdirectory has its own INDEX.md but the parent
#                INDEX.md does not link to it.
#
# This is intentionally a permissive substring/path heuristic — false
# negatives are preferred over false positives so the script doesn't
# block PRs on ambiguous cases.
#
# Exit codes:
#   0  no findings
#   1  any [UNLISTED] / [BROKEN] / [ORPHAN] finding

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

fail=0

# Find all directories that have an INDEX.md.
mapfile -t INDEX_FILES < <(find . -type f -name 'INDEX.md' \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  | sort)

for index in "${INDEX_FILES[@]}"; do
  dir="$(dirname "$index")"
  echo "== $index =="

  # ---------- [UNLISTED] — sibling .md files not referenced ----------

  mapfile -t siblings < <(find "$dir" -maxdepth 1 -type f -name '*.md' \
    ! -name 'INDEX.md' | sort)

  if [[ ${#siblings[@]} -eq 0 ]]; then
    echo "  (no sibling .md files)"
  else
    for f in "${siblings[@]}"; do
      base="$(basename "$f")"
      if grep -q -F -- "$base" "$index"; then
        echo "  [OK]       $base"
      else
        echo "  [UNLISTED] $base — not referenced by $index"
        fail=1
      fi
    done
  fi

  # ---------- [BROKEN] — relative links pointing at missing files ----------
  #
  # Pull markdown link targets that look like relative paths: anything in
  # `](path)` where `path` doesn't start with http(s):// and isn't an
  # in-page anchor. Resolve each against the index's directory and check
  # existence. Tolerates trailing #anchor and ?query fragments.

  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    # Strip anchor / query.
    clean="${target%%#*}"
    clean="${clean%%\?*}"
    [[ -z "$clean" ]] && continue
    # Resolve against the index's directory.
    resolved="$dir/$clean"
    if [[ -e "$resolved" ]]; then
      :
    else
      echo "  [BROKEN]   link to $target — resolves to missing $resolved"
      fail=1
    fi
  done < <(
    grep -oE '\]\([^)]+\)' "$index" 2>/dev/null \
      | sed -E 's/^\]\(//; s/\)$//' \
      | grep -vE '^(https?://|mailto:|#)' \
      | grep -vE '^/' \
      || true
  )

  # ---------- [ORPHAN] — subdirectory has INDEX.md but parent doesn't link to it ----------

  while IFS= read -r sub_index; do
    [[ -z "$sub_index" ]] && continue
    sub_dir="$(dirname "$sub_index")"
    sub_name="$(basename "$sub_dir")"
    # Match either bare subdir reference "subname/" or path-to-its-INDEX.md.
    if grep -qE "(^|[\"\\'\\(/])${sub_name}/(INDEX\\.md)?" "$index" 2>/dev/null \
       || grep -qF -- "$sub_name/INDEX.md" "$index" 2>/dev/null \
       || grep -qF -- "${sub_name}/" "$index" 2>/dev/null; then
      :
    else
      echo "  [ORPHAN]   $sub_dir has INDEX.md but $index doesn't link to it"
      fail=1
    fi
  done < <(
    find "$dir" -mindepth 2 -maxdepth 2 -type f -name 'INDEX.md' 2>/dev/null | sort
  )
done

echo
if [[ $fail -ne 0 ]]; then
  echo "validate-doc-indexes: FAIL"
  exit 1
fi
echo "validate-doc-indexes: PASS"
