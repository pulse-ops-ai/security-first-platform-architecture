---
# security-first-adoption.md
#
# Adoption record. Lives at the root of every consuming repo. The
# repo-healthcheck skill fails when any required field is empty.
#
# YAML frontmatter holds the machine-readable fields validators check;
# the prose body below explains intent for human reviewers.

adopting_repo:        # e.g., "trupryce"
architecture_repo:    https://github.com/pulse-ops-ai/security-first-platform-architecture
architecture_ref:     # SHA, tag, or branch — REQUIRED, no defaults
architecture_ref_kind: # one of: sha | tag | branch
adoption_date:        # ISO 8601, e.g., 2026-05-20
last_review_date:     # ISO 8601, blank on first adoption
next_review_date:     # ISO 8601, per review_cadence below
review_cadence:       # one of: monthly | quarterly | per-release | on-architecture-change
owner:                # GitHub handle of the human owner (not a team)
owning_team:          # GitHub Enterprise team slug, if applicable

# ---- Architecture posture ----

profile:              # one of: self-hosted-vps | aws-managed | hybrid-tailnet | <other>
adopted_control_layers:
  # List each of the 8 layers the consuming repo implements. Use
  # "implemented" if this repo owns the implementation, "consumed" if it
  # depends on another component, or "n/a" if the layer doesn't apply.
  l1_network_reachability:    # implemented | consumed | n/a
  l2_edge_gateway:            # implemented | consumed | n/a
  l3_identity:                # implemented | consumed | n/a
  l4_authorization:           # implemented | consumed | n/a
  l5_operational_guardrails:  # implemented | consumed | n/a
  l6_orchestrator_bff:        # implemented | consumed | n/a
  l7_service_enforcement:     # implemented | consumed | n/a
  l8_semantic_agent:          # implemented | consumed | n/a

# ---- Deviations and compensating controls ----

# A "deviation" is anywhere this consumer departs from the architecture
# repo at the pinned ref. Each deviation MUST have a compensating control.
deviations: []
# Example:
# deviations:
#   - id: DEV-001
#     description: "L4 authorization is permit-by-default for internal admin API"
#     reason: "Internal admin tooling pre-dates Verified Permissions migration"
#     compensating_control: "Admin API is on a private subnet, MFA-gated, audit-logged to sealed index"
#     scheduled_remediation: 2026-Q3
#     openspec_ref: openspec/proposals/2026-04-15-admin-api-migration/

# ---- OpenSpec changes required to reach the pinned ref ----

# Tier 2/3 OpenSpec proposals in the architecture repo that this consumer
# has not yet integrated. Empty list means consumer is current with the
# pinned ref.
pending_openspec_changes: []
# Example:
# pending_openspec_changes:
#   - openspec_ref: https://github.com/.../openspec/proposals/2026-05-10-envelope-claims/
#     target_completion: 2026-06-30
#     impact: "BFF must adopt new envelope claim 'agent_actor_chain'"

# ---- Cross-repo dependencies ----

# Dependency records this consumer participates in. Links to the
# architecture-repo portfolio/dependencies/ entries.
cross_repo_dependencies: []
# Example:
# cross_repo_dependencies:
#   - dependency_id: DEP-2026-05-20-001
#     role: downstream   # upstream | downstream
#     url: https://github.com/.../portfolio/dependencies/2026-05-20-trupryce-depends-on-architecture-envelope-claims.md

# ---- Vendor / adapter tooling currently used by this repo ----
# Used to decide which vendor-adapter files validators expect.
agent_adapters_in_use:
  claude_code:        # true | false
  codex:              # true | false
  github_copilot:     # true | false
  cursor:             # true | false
  other: []           # list any others
---

# Security-First Platform Architecture — Adoption Record

> Copy this file into the root of your consuming repo and fill in every field above. Empty required fields fail the `repo-healthcheck` skill. The prose section below is for human context — write it once, update on every review.

## Why this repo adopted the security-first platform architecture

<!-- 1–3 paragraphs. What problem does adoption solve here? What were the alternatives? -->

## What "alignment" means for this repo specifically

<!-- Restate the spirit of standards/security-first-architecture-standard.md in this repo's terms. Reference the specific control layers and the specific deployment profile. Call out anything unusual. -->

## Deviations and compensating controls

<!-- For each entry in the `deviations` field above, expand on the reason, the compensating control's reliability, and the path back to full alignment. -->

## Review record

<!-- Append-only. Add an entry on every review. -->

| Date | Reviewer | Architecture ref reviewed | Findings | Next review |
|---|---|---|---|---|
| YYYY-MM-DD | @handle | <sha or tag> | summary | YYYY-MM-DD |

## How to update this file

1. On every architecture-repo Tier 2/3 change that affects this consumer, add an entry to `pending_openspec_changes` and `cross_repo_dependencies` as appropriate.
2. On every review (per `review_cadence`), update `last_review_date`, `next_review_date`, and add a row to the **Review record** table.
3. When this consumer moves to a new architecture-repo ref, update `architecture_ref` and `architecture_ref_kind` and confirm `pending_openspec_changes` is empty before considering the adoption complete.
4. Never edit the `deviations` list silently. Every deviation requires a compensating control and an OpenSpec proposal (or a documented decision to remain deviated).
