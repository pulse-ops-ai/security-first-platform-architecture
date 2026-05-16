#!/usr/bin/env bash
# validate-architecture.sh
#
# Lightweight scaffold for the architecture-healthcheck workflow.
# Confirms required architecture files exist and that vendor names
# do not leak into vendor-neutral docs.
#
# This is a starting point; extend over time as the architecture matures.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

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

echo
echo "== Vendor-name leakage check =="
# Vendor-neutral docs must not name specific vendors. This is a heuristic;
# extend the list as needed. The 'profiles/' subdirectory is excluded.
VENDOR_PATTERNS=(
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
for pattern in "${VENDOR_PATTERNS[@]}"; do
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

echo
if [[ $fail -ne 0 ]]; then
  echo "validate-architecture: FAIL"
  exit 1
fi
echo "validate-architecture: PASS"
