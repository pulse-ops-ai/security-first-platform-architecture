#!/usr/bin/env bash
# check-network-as-identity.sh
#
# Heuristic scanner for the most common "trust the network as identity"
# smells. Designed to be invoked by the security-control-review skill
# and run locally against a consuming repo's source tree.
#
# This is intentionally a HEURISTIC. It produces findings that a human
# reviewer must triage — false positives are expected (logging, debug
# pages, audit trails). False negatives are also expected (custom
# authentication libraries we don't recognize). Treat findings as a
# prompt to look closer, not as a definitive verdict.
#
# Architecture references:
#   architecture/security-boundaries.md
#   architecture/agent-as-client-model.md
#   architecture/identity-and-authorization.md
#
# Usage:
#   bash scripts/check-network-as-identity.sh           # scan current dir
#   bash scripts/check-network-as-identity.sh <path>    # scan a specific tree
#
# Exit codes:
#   0  no findings
#   1  findings reported (skill should treat as WARN, not BLOCK)
#   2  invocation error

set -uo pipefail

ROOT="${1:-.}"

if [[ ! -d "$ROOT" ]]; then
  echo "ERROR: target path is not a directory: $ROOT" >&2
  exit 2
fi

# Prefer ripgrep when available; fall back to grep -rEn.
if command -v rg >/dev/null 2>&1; then
  SEARCH() { rg -n --hidden --no-heading --no-messages "$@" "$ROOT" 2>/dev/null; }
else
  SEARCH() {
    # Translate "-t <lang>" args to grep's --include
    local include_args=()
    local rg_args=()
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -t) shift; include_args+=(--include="*.$1"); shift ;;
        *)  rg_args+=("$1"); shift ;;
      esac
    done
    grep -rEn --color=never \
      --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.venv \
      --exclude-dir=dist --exclude-dir=build --exclude-dir=target \
      "${include_args[@]}" "${rg_args[@]}" "$ROOT" 2>/dev/null
  }
fi

FINDINGS=0

report() {
  local category="$1" finding="$2"
  echo "[$category] $finding"
  FINDINGS=$((FINDINGS + 1))
}

# ---------- 1. Client-IP-as-identity smells ----------
# Code that READS the client IP and uses it for an authz / identity
# decision, rather than for logging or rate-limiting.
#
# We look for client-IP getters in the same line or block as authz/permit
# keywords. This catches "if request.client.host in admin_ips" patterns.

echo "== Client-IP-as-identity smells =="

# X-Forwarded-For / X-Real-IP / RemoteAddr / req.ip / request.client.host
IP_GETTERS_RE='X-Forwarded-For|X-Real-IP|RemoteAddr|req\.ip|request\.client\.host|getRemoteAddr|HTTP_X_FORWARDED_FOR'

# Authz / decision keywords
AUTHZ_RE='allow|permit|deny|authoriz|isAdmin|is_admin|hasRole|has_role|trust|whitelist|allowlist'

# Scan source files (most common implementation languages).
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # Filter to lines that ALSO contain an authz term within ~2 lines.
  # Simpler: only flag if both regex hit on the same line.
  if echo "$line" | grep -qiE "$AUTHZ_RE"; then
    report "ip-as-identity" "$line"
  fi
done < <(
  SEARCH -E "$IP_GETTERS_RE" -t go -t ts -t js -t py -t java -t rs -t rb 2>/dev/null
)

# ---------- 2. Internal-CIDR-as-identity smells ----------
# Hard-coded private CIDRs used in conditional branches that decide
# permission. Logging / metrics references are usually fine.

echo
echo "== Internal-CIDR-as-identity smells =="

CIDR_RE='\b(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)[0-9]+\.[0-9]+/[0-9]+'

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # Filter: only flag if line ALSO contains a decision verb.
  if echo "$line" | grep -qiE 'allow|permit|trust|whitelist|allowlist|if .*ip|isInternal'; then
    report "internal-cidr-trust" "$line"
  fi
done < <(
  SEARCH -E "$CIDR_RE" -t go -t ts -t js -t py -t java -t rs -t rb 2>/dev/null
)

# ---------- 3. Service-mesh-only identity smells ----------
# Code that pulls a SPIFFE ID, mTLS peer cert subject, or workload
# identity claim and uses it WITHOUT verifying an end-user identity
# token. Pure workload identity is fine for service-to-service; it must
# not stand alone when the call is on behalf of a user/agent.

echo
echo "== Service-mesh-only identity smells =="

# Look for spiffe:// or peer-cert reads near authz decisions.
MESH_RE='spiffe://|peer\.cert|peer\.identity|workload\.identity|x509\.subject|TLS_CLIENT'

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  if echo "$line" | grep -qiE "$AUTHZ_RE|user|actor|on_behalf"; then
    report "mesh-only-identity" "$line"
  fi
done < <(
  SEARCH -E "$MESH_RE" -t go -t ts -t js -t py -t java -t rs -t rb 2>/dev/null
)

# ---------- 4. Fail-open authz smells ----------
# try/catch around an authz call that returns permit, OR boolean default
# `true` on a permission-decision variable.

echo
echo "== Fail-open authz smells =="

# Multi-line patterns are hard in bash. Single-line approximations:
#   - "catch ... return true"
#   - "default: permit"
#   - "permission = true" / "allowed = true"
FAIL_OPEN_RE='catch.*\b(return|throw)\b.*\b(true|permit|allow)\b|default[^=]*=[[:space:]]*(permit|allow|true)\b|(allow|permit|granted|authoriz\w+)[[:space:]]*=[[:space:]]*true\b'

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  report "fail-open" "$line"
done < <(
  SEARCH -E "$FAIL_OPEN_RE" -t go -t ts -t js -t py -t java -t rs -t rb 2>/dev/null
)

# ---------- 5. Long-lived credential smells ----------
# Hard-coded AWS access keys or unmistakable JWT-shaped literals near
# variable names suggesting tokens. detect-secrets and gitleaks cover
# the high-entropy / signature cases; this catches the "looks like an
# example but isn't" cases by name.

echo
echo "== Long-lived credential smells =="

LONG_LIVED_RE='\b(AKIA[A-Z0-9]{16})\b|\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+\b'

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # Mask the value when reporting — do not echo real keys.
  masked=$(echo "$line" | sed -E 's/(AKIA[A-Z0-9]{4})[A-Z0-9]+/\1...REDACTED.../; s/(eyJ[A-Za-z0-9_-]{4})[A-Za-z0-9_.-]+/\1...REDACTED.../')
  report "long-lived-cred" "$masked"
done < <(
  SEARCH -E "$LONG_LIVED_RE" -t go -t ts -t js -t py -t java -t rs -t rb -t yaml -t json 2>/dev/null
)

# ---------- Summary ----------

echo
if [[ $FINDINGS -eq 0 ]]; then
  echo "check-network-as-identity: PASS (0 findings)"
  exit 0
fi
echo "check-network-as-identity: $FINDINGS finding(s) — review each above"
echo
echo "These are HEURISTIC findings. Review each one against the security-boundaries.md crossing rules and the agent-as-client model. False positives are expected (logging, rate-limiting, audit). The skill should treat these as WARN, not BLOCK."
exit 1
