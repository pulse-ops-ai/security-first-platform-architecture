#!/usr/bin/env bash
# validate-doc-indexes.sh
#
# Lightweight scaffold for the docs-healthcheck workflow.
# For each directory containing an INDEX.md, confirm that every sibling
# *.md file is referenced from the index (heuristic: filename appears
# anywhere in the index file).
#
# This is intentionally permissive (substring match). Tighten over time
# if false negatives become a problem.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0

# Find all directories that have an INDEX.md.
mapfile -t INDEX_FILES < <(find . -type f -name 'INDEX.md' \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  | sort)

for index in "${INDEX_FILES[@]}"; do
  dir="$(dirname "$index")"
  echo "== $index =="

  # List sibling .md files (depth 1), excluding INDEX.md itself.
  mapfile -t siblings < <(find "$dir" -maxdepth 1 -type f -name '*.md' \
    ! -name 'INDEX.md' | sort)

  if [[ ${#siblings[@]} -eq 0 ]]; then
    echo "  (no sibling .md files)"
    continue
  fi

  for f in "${siblings[@]}"; do
    base="$(basename "$f")"
    if grep -q -F -- "$base" "$index"; then
      echo "  [OK]       $base"
    else
      echo "  [UNLISTED] $base — not referenced by $index"
      fail=1
    fi
  done
done

echo
if [[ $fail -ne 0 ]]; then
  echo "validate-doc-indexes: FAIL"
  exit 1
fi
echo "validate-doc-indexes: PASS"
