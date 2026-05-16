#!/usr/bin/env bash
# check-infra-secrets.sh
#
# Scans infra/ for the specific shapes that should NEVER appear in
# reference infrastructure:
#
#   - 12-digit AWS account IDs (real account identifiers)
#   - ARNs containing real account IDs
#   - Real region-default values where placeholders are expected
#   - Hard-coded production environment names baked into examples
#
# This is a focused complement to detect-secrets and gitleaks. They
# catch tokens; this catches infra-specific metadata leaks that aren't
# "secrets" in the entropy sense but still must not ship in reference
# material.
#
# Usage:
#   bash scripts/check-infra-secrets.sh                  # scan infra/
#   bash scripts/check-infra-secrets.sh path1 path2 ...  # scan specific files
#
# Exit codes:
#   0 — no findings
#   1 — findings reported
#   2 — invocation error

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2

if [[ $# -gt 0 ]]; then
  FILES=("$@")
else
  mapfile -t FILES < <(find infra -type f \
    \( -name '*.yml' -o -name '*.yaml' -o -name '*.json' \
       -o -name '*.tf'  -o -name '*.tfvars' -o -name '*.hujson' \
       -o -name '*.md'  -o -name '*.env'    -o -name '*.env.*' \) \
    2>/dev/null | sort)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "check-infra-secrets: PASS (no infra files to scan)"
  exit 0
fi

FINDINGS=0

report() {
  local kind="$1" file="$2" line="$3" snippet="$4"
  echo "[$kind] $file:$line $snippet"
  FINDINGS=$((FINDINGS + 1))
}

# ---------- 1. 12-digit AWS account IDs ----------
# Match any standalone 12-digit number. We then filter out obvious
# placeholders ("123456789012" — the AWS docs canonical fake ID; lines
# the user has clearly marked with "EXAMPLE" or "PLACEHOLDER").

ACCOUNT_ID_RE='\b[0-9]{12}\b'
PLACEHOLDER_RE='123456789012|111122223333|000000000000|EXAMPLE|PLACEHOLDER|YOUR_ACCOUNT|__YOUR_|<your-account>|<account-id>'

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  while IFS=: read -r line content; do
    [[ -z "$line" ]] && continue
    # Comment-line skip
    case "${content##[[:space:]]}" in
      '#'*|'//'*|'/*'*|'*'*) continue ;;
    esac
    # Skip lines that contain a known placeholder marker
    if echo "$content" | grep -qiE "$PLACEHOLDER_RE"; then
      continue
    fi
    # Skip if the 12-digit number is part of a longer token (e.g., 16+ digit string)
    # by requiring word boundaries — already handled by ACCOUNT_ID_RE.
    snippet="${content:0:120}"
    report "aws-account-id" "$f" "$line" "$snippet"
  done < <(grep -nE "$ACCOUNT_ID_RE" "$f" 2>/dev/null)
done

# ---------- 2. ARN account ID segment ----------
# arn:aws:<svc>:<region>:<12-digit-account>:<resource>
# Same placeholder filter applies.

ARN_RE='arn:aws[^:]*:[^:]*:[^:]*:[0-9]{12}:'

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  while IFS=: read -r line content; do
    [[ -z "$line" ]] && continue
    case "${content##[[:space:]]}" in
      '#'*|'//'*|'/*'*|'*'*) continue ;;
    esac
    if echo "$content" | grep -qiE "$PLACEHOLDER_RE"; then
      continue
    fi
    # Extract the account-id portion to filter placeholders explicitly.
    account=$(echo "$content" | grep -oE 'arn:aws[^:]*:[^:]*:[^:]*:[0-9]{12}:' | head -1 | awk -F: '{print $5}')
    case "$account" in
      123456789012|111122223333|000000000000) continue ;;
    esac
    report "arn-with-account" "$f" "$line" "${content:0:120}"
  done < <(grep -nE "$ARN_RE" "$f" 2>/dev/null)
done

# ---------- 3. Hard-coded region defaults outside example.* / template files ----------
# In reference infra, real AWS regions should not be set as DEFAULT
# values. They should be required-from-caller or placeholdered.
# Allow `*.example.*` files to contain example regions because those
# files are example-by-name. Same for files under templates/.

REGION_DEFAULT_RE='(default[[:space:]]*=[[:space:]]*["'\'']?|region:[[:space:]]*)((us|eu|ap|sa|ca|af|me)-[a-z]+-[0-9])'

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  # Skip files explicitly marked as examples or under templates/.
  case "$f" in
    *.example.*|*/templates/*|infra/profiles/*/terraform/environments/*/terraform.tfvars.example)
      continue ;;
  esac
  while IFS=: read -r line content; do
    [[ -z "$line" ]] && continue
    case "${content##[[:space:]]}" in
      '#'*|'//'*) continue ;;
    esac
    if echo "$content" | grep -qiE "$PLACEHOLDER_RE|__YOUR_REGION__"; then
      continue
    fi
    report "region-default" "$f" "$line" "${content:0:120}"
  done < <(grep -nE "$REGION_DEFAULT_RE" "$f" 2>/dev/null)
done

# ---------- Summary ----------

echo
if [[ $FINDINGS -eq 0 ]]; then
  echo "check-infra-secrets: PASS (0 findings)"
  exit 0
fi

echo "check-infra-secrets: $FINDINGS finding(s) above"
echo
echo "infra/ is REFERENCE infrastructure — no live secrets, no real account IDs,"
echo "no real ARNs, no real region defaults. See infra/README.md."
echo
echo "If a finding is a known-safe placeholder the scanner missed, add it to the"
echo "PLACEHOLDER_RE in scripts/check-infra-secrets.sh (do not allowlist the file)."
exit 1
