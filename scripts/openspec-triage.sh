#!/usr/bin/env bash
# openspec-triage.sh
#
# Classifies a PR's diff into Tier 1 / Tier 2 / Tier 3 per
# team-os/openspec-policy.md, then verifies that any required OpenSpec
# proposal is present and well-formed.
#
# Usage:
#   bash scripts/openspec-triage.sh                 # diff against origin/main
#   bash scripts/openspec-triage.sh <base-ref>      # diff against <base-ref>
#
# Exit codes:
#   0  PASS — Tier 1, or Tier 2/3 with a present, well-formed proposal
#   1  BLOCK — Tier 2/3 with no proposal or malformed proposal
#   2  invocation error

set -uo pipefail

BASE_REF="${1:-origin/main}"

# Make sure we have the base ref locally.
if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  echo "ERROR: base ref '$BASE_REF' not found locally" >&2
  exit 2
fi

# ---------- Diff ----------

mapfile -t CHANGED_FILES < <(git diff --name-only "${BASE_REF}...HEAD" 2>/dev/null | sort -u)

if [[ ${#CHANGED_FILES[@]} -eq 0 ]]; then
  echo "openspec-triage: PASS — no files changed from $BASE_REF"
  exit 0
fi

echo "Changed files (${#CHANGED_FILES[@]}):"
for f in "${CHANGED_FILES[@]}"; do
  echo "  $f"
done
echo

# ---------- Tier classification ----------
#
# Rules (mirror team-os/openspec-policy.md):
#
# Tier 3 — cross-repo architecture or security-boundary change:
#   architecture/control-layers.md
#   architecture/principles.md
#   architecture/agent-as-client-model.md
#   architecture/internal-identity-envelope.md
#   architecture/security-boundaries.md
#   architecture/multi-tenancy.md
#   standards/repo-contract.md  (changes to the Universal Floor)
#   team-os/openspec-policy.md  (changes to the tiering itself)
#
# Tier 2 — repo contract / standard / template / skill / CI / OpenSpec / architecture behavior:
#   any other architecture/*.md or architecture/profiles/*.md
#   standards/*.md
#   templates/**
#   .agents/skills/**
#   .github/workflows/**
#   .github/CODEOWNERS
#   .pre-commit-config.yaml
#   scripts/**  (when the script is part of a CI gate)
#   AGENTS.md
#   CLAUDE.md
#   team-os/**
#
# Tier 1 — everything else.

TIER=1
TIER_REASONS=()

is_tier3_file() {
  case "$1" in
    architecture/control-layers.md|\
    architecture/principles.md|\
    architecture/agent-as-client-model.md|\
    architecture/internal-identity-envelope.md|\
    architecture/security-boundaries.md|\
    architecture/multi-tenancy.md|\
    standards/repo-contract.md|\
    team-os/openspec-policy.md)
      return 0 ;;
    *) return 1 ;;
  esac
}

is_tier2_file() {
  case "$1" in
    architecture/profiles/*.md|architecture/*.md|\
    standards/*.md|\
    templates/*)
      return 0 ;;
  esac
  case "$1" in
    .agents/skills/*)            return 0 ;;
    .github/workflows/*)         return 0 ;;
    .github/CODEOWNERS)          return 0 ;;
    .pre-commit-config.yaml)     return 0 ;;
    scripts/*)                   return 0 ;;
    AGENTS.md|CLAUDE.md)         return 0 ;;
    team-os/*)                   return 0 ;;
  esac
  return 1
}

for f in "${CHANGED_FILES[@]}"; do
  if is_tier3_file "$f"; then
    TIER=3
    TIER_REASONS+=("$f → Tier 3 (cross-repo architecture / security boundary)")
  elif is_tier2_file "$f"; then
    [[ $TIER -lt 2 ]] && TIER=2
    TIER_REASONS+=("$f → Tier 2")
  fi
done

echo "Tier classification: $TIER"
if [[ ${#TIER_REASONS[@]} -gt 0 ]]; then
  echo "Reasons:"
  for r in "${TIER_REASONS[@]}"; do
    echo "  - $r"
  done
fi
echo

# ---------- Tier 1 → done ----------

if [[ $TIER -eq 1 ]]; then
  echo "openspec-triage: PASS (Tier 1 — no OpenSpec required)"
  exit 0
fi

# ---------- Tier 2/3 → proposal must exist in the diff ----------

# Look for a proposal directory under openspec/proposals/ that was
# touched by this PR.
mapfile -t TOUCHED_PROPOSAL_DIRS < <(
  printf '%s\n' "${CHANGED_FILES[@]}" \
    | grep -E '^openspec/proposals/[0-9]{4}-[0-9]{2}-[0-9]{2}-[^/]+/' \
    | sed -E 's|^(openspec/proposals/[0-9]{4}-[0-9]{2}-[0-9]{2}-[^/]+)/.*|\1|' \
    | sort -u
)

if [[ ${#TOUCHED_PROPOSAL_DIRS[@]} -eq 0 ]]; then
  cat <<EOF
[BLOCK] Tier $TIER change with no OpenSpec proposal in this PR.

Per team-os/openspec-policy.md, every Tier 2/3 change requires an
OpenSpec proposal. Create one using:

  templates/openspec/proposal-template.md
  templates/openspec/change-template.md
  templates/openspec/tasks-template.md

at:

  openspec/proposals/$(date -u +%Y-%m-%d)-<short-title>/

openspec-triage: FAIL
EOF
  exit 1
fi

# ---------- Validate every touched proposal ----------

PROBLEMS=0

for dir in "${TOUCHED_PROPOSAL_DIRS[@]}"; do
  echo "== $dir =="
  for required in proposal.md change.md tasks.md; do
    if [[ -f "$dir/$required" ]]; then
      echo "  [OK]      $required present"
    else
      echo "  [MISSING] $required"
      PROBLEMS=$((PROBLEMS + 1))
    fi
  done

  # proposal.md must declare tier and completion_state in frontmatter.
  if [[ -f "$dir/proposal.md" ]]; then
    fm=$(awk 'NR==1 && $0=="---" { in_fm=1; next }
              in_fm==1 && $0=="---" { exit }
              in_fm==1 { print }' "$dir/proposal.md")
    if ! grep -q '^tier:' <<<"$fm"; then
      echo "  [MISSING] proposal.md frontmatter 'tier:'"
      PROBLEMS=$((PROBLEMS + 1))
    fi
    if ! grep -q '^completion_state:' <<<"$fm"; then
      echo "  [MISSING] proposal.md frontmatter 'completion_state:'"
      PROBLEMS=$((PROBLEMS + 1))
    fi
    # Tier 3 forbids architecture-complete.
    if grep -q '^tier:[[:space:]]*3' <<<"$fm" && \
       grep -q '^completion_state:[[:space:]]*architecture-complete' <<<"$fm"; then
      echo "  [BLOCK]   Tier 3 proposal cannot target 'architecture-complete'"
      PROBLEMS=$((PROBLEMS + 1))
    fi
  fi

  # tasks.md must declare completion_state.
  if [[ -f "$dir/tasks.md" ]]; then
    if ! head -n 5 "$dir/tasks.md" | grep -q '^completion_state:'; then
      echo "  [MISSING] tasks.md frontmatter 'completion_state:'"
      PROBLEMS=$((PROBLEMS + 1))
    fi
  fi
done

echo
if [[ $PROBLEMS -gt 0 ]]; then
  echo "openspec-triage: FAIL ($PROBLEMS issue(s) — see above)"
  exit 1
fi

echo "openspec-triage: PASS (Tier $TIER with well-formed proposal)"
exit 0
