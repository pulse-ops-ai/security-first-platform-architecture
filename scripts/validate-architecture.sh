#!/usr/bin/env bash
# validate-architecture.sh
#
# Enforces that vendor names and vendor-specific files do not leak into
# the neutral-core of the architecture / TeamOS / standards docs.
#
# Three checks (each fails the script on violation):
#
#   1. Required architecture files exist.
#   2. Vendor-NAME leakage (Cloudflare, Tailscale, Kong, Cognito, ...) in
#      architecture/*.md (depth 1; profiles/ is excluded — vendors are
#      named there on purpose).
#   3. Vendor-FILE-as-universally-required leakage in team-os/ and
#      standards/. The contract is that `AGENTS.md` is the universal
#      floor; `CLAUDE.md`, `.claude/`, `.codex/`, `.cursorrules`, etc.
#      are vendor-specific adapters and required ONLY when that tool is
#      in use. Lines that list these files near words like "required",
#      "must", "every repo", "floor", or "mandatory" — without nearby
#      conditional modifiers ("if", "when", "only", "optional",
#      "adapter", "vendor-specific", "example") — are flagged.
#
# Limitations:
#   - The conditional-modifier check looks at a 3-line window (line and
#     the lines above/below). It will miss conditionals that are 4+
#     lines away and may false-positive when the conditional language
#     is implicit. Reviewers should treat warnings as a prompt to add
#     explicit "(only when used)" language.
#   - The script intentionally allow-lists files that legitimately
#     document the adapter pattern in full
#     (standards/agent-instructions-standard.md, standards/repo-contract.md,
#     templates/, .claude/**, .codex/**, .github/copilot-instructions.md).
#     In those files, vendor file names are expected.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

fail=0

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "[MISSING] $path"
    fail=1
  else
    echo "[OK]      $path"
  fi
}

# ---------- Check 1: required architecture documents exist ----------

echo "== Required architecture documents =="
require_file "architecture/INDEX.md"
require_file "architecture/overview.md"
require_file "architecture/principles.md"
require_file "architecture/control-layers.md"
require_file "architecture/reference-topology.md"
require_file "architecture/security-boundaries.md"
require_file "architecture/identity-and-authorization.md"
require_file "architecture/internal-identity-envelope.md"
require_file "architecture/agent-as-client-model.md"
require_file "architecture/multi-tenancy.md"
require_file "architecture/observability.md"
require_file "architecture/deployment-profiles.md"

echo
echo "== Required profiles =="
require_file "architecture/profiles/README.md"
require_file "architecture/profiles/self-hosted-vps.md"
require_file "architecture/profiles/aws-managed.md"
require_file "architecture/profiles/hybrid-tailnet.md"

# ---------- Check 2: vendor-NAME leakage in architecture/*.md ----------

echo
echo "== Vendor-name leakage check (architecture/*.md, profiles/ excluded) =="

VENDOR_NAME_PATTERNS=(
  "Cloudflare"
  "Tailscale"
  "Kong"
  "Traefik"
  "Keycloak"
  "OpenFGA"
  "Cognito"
  "Auth0"
  "Verified Permissions"
  "API Gateway"
  "CloudWatch"
  "Splunk"
)

LEAK_SCOPE=$(find architecture -maxdepth 1 -type f -name '*.md' | sort)

leak_found=0
for pattern in "${VENDOR_NAME_PATTERNS[@]}"; do
  if echo "$LEAK_SCOPE" | xargs grep -l -- "$pattern" 2>/dev/null >/tmp/__leak.$$; then
    while read -r f; do
      echo "[LEAK]    $f mentions '$pattern' — vendor names belong in architecture/profiles/"
      leak_found=1
    done </tmp/__leak.$$
  fi
  rm -f /tmp/__leak.$$
done

if [[ $leak_found -eq 0 ]]; then
  echo "[OK]      no vendor names in architecture/*.md"
else
  fail=1
fi

# ---------- Check 3: vendor-FILE-as-universal in team-os/ and standards/ ----------

echo
echo "== Vendor-file-as-universal leakage in team-os/ and standards/ =="

# Vendor adapter file/path tokens we look for.
VENDOR_FILE_PATTERNS=(
  "CLAUDE.md"
  "\\.claude/"
  "\\.codex/"
  "\\.cursorrules"
  "copilot-instructions"
)

# "Required"-style words that, without a conditional modifier nearby,
# imply universal requirement.
REQUIRED_TERMS_RE='(^|[^a-z])(required|must|every repo|every consuming|floor|mandatory|every consumer)'

# Conditional/modifier words that scope the requirement to specific cases.
CONDITIONAL_TERMS_RE='(^|[^a-z])(if|when|only when|optional|adapter|vendor-specific|example|recommended|in use|use case|opt-in)'

# Files that legitimately document the adapter pattern in full and may
# list vendor file names without conditional language nearby (because
# the surrounding doc is itself about adapters).
ADAPTER_DOC_ALLOWLIST=(
  "standards/agent-instructions-standard.md"
  "standards/repo-contract.md"
)

is_adapter_doc_allowlisted() {
  local file="$1"
  local allowed
  for allowed in "${ADAPTER_DOC_ALLOWLIST[@]}"; do
    [[ "$file" == "$allowed" ]] && return 0
  done
  return 1
}

# Scan in-scope files: everything under team-os/ and standards/, plus
# architecture/overview.md (the front door).
mapfile -t IN_SCOPE_FILES < <(
  {
    find team-os -type f -name '*.md'
    find standards -type f -name '*.md'
    [[ -f architecture/overview.md ]] && echo "architecture/overview.md"
  } | sort -u
)

vendor_file_leak_found=0

for file in "${IN_SCOPE_FILES[@]}"; do
  if is_adapter_doc_allowlisted "$file"; then
    continue
  fi
  for pattern in "${VENDOR_FILE_PATTERNS[@]}"; do
    while IFS=: read -r lineno content; do
      [[ -z "$lineno" ]] && continue

      # Look at the 3-line window around the match.
      window_start=$((lineno - 1)); (( window_start < 1 )) && window_start=1
      window_end=$((lineno + 1))
      window="$(sed -n "${window_start},${window_end}p" "$file")"

      # Does the matched line itself contain a "required" word?
      if ! echo "$content" | grep -qiE "$REQUIRED_TERMS_RE"; then
        # No "required" language on the matched line — not a leak.
        continue
      fi

      # Is there a conditional modifier in the window?
      if echo "$window" | grep -qiE "$CONDITIONAL_TERMS_RE"; then
        # Conditional language present — properly scoped.
        continue
      fi

      echo "[LEAK]    $file:$lineno '$pattern' implied universally required without conditional modifier"
      echo "          → $(echo "$content" | head -c 140)"
      vendor_file_leak_found=1
    done < <(grep -nE "$pattern" "$file" 2>/dev/null || true)
  done
done

# Also flag parenthetical vendor-name lists like "(Claude Code, Codex)"
# which almost always indicate vendor-list pollution in neutral prose.
PARENTHETICAL_VENDOR_RE='\([^)]*\b(Claude|Codex|Cursor|Aider)\b[^)]*\b(Claude|Codex|Cursor|Aider)\b[^)]*\)'

paren_leak_found=0
for file in "${IN_SCOPE_FILES[@]}"; do
  if is_adapter_doc_allowlisted "$file"; then
    continue
  fi
  while IFS=: read -r lineno content; do
    [[ -z "$lineno" ]] && continue
    echo "[LEAK]    $file:$lineno parenthetical vendor list: $(echo "$content" | head -c 140)"
    paren_leak_found=1
  done < <(grep -nE "$PARENTHETICAL_VENDOR_RE" "$file" 2>/dev/null || true)
done

if [[ $vendor_file_leak_found -eq 0 && $paren_leak_found -eq 0 ]]; then
  echo "[OK]      no vendor-file-as-universal leakage in team-os/ or standards/"
else
  fail=1
fi

echo
if [[ $fail -ne 0 ]]; then
  echo "validate-architecture: FAIL"
  exit 1
fi
echo "validate-architecture: PASS"
