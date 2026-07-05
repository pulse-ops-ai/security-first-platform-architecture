---
# Dependency record — required schema.
#
# Every field is REQUIRED. Leave a field as "n/a" if it truly does not
# apply; do not omit the key. Validators check field presence, not values.

dependency_id:                DEP-2026-07-05-001
title:                        trupryce pins its architecture_ref from v0.2.0 to v0.3.0
upstream_repo:                security-first-platform-architecture
upstream_ref:                 v0.3.0
upstream_ref_kind:            tag
upstream_artifact:            architecture/ + standards/ at v0.3.0. Delta vs v0.2.0 is additive/non-normative — diagram archetype templates, standards/diagramming-conventions.md, and a validate-diagrams step in the docs-healthcheck reusable workflow; internal-identity-envelope.md, the ADRs, control-layers.md, and the deployment-profile docs are byte-identical across v0.2.0..v0.3.0.
downstream_repo:              trupryce
downstream_artifact:          security-first-adoption.md (architecture_ref); .github/workflows/{pre-commit,docs-healthcheck,repo-healthcheck}.yml (reusable-workflow @ref + architecture_ref: inputs)
dependency_type:              contract
impact_tier:                  2
status:                       open
blocking_direction:           blocks-downstream
required_by:                  n/a
deprecation_window:           n/a
coordinated_landing_order:    upstream-first
owner:                        "@mikegtech"
opened_date:                  2026-07-05
resolved_date:                
related_openspec_proposal:    trupryce:openspec/proposals/2026-07-05-architecture-ref-v0.3.0-pin/proposal.md
notes:                        Filed because trupryce's AGENTS.md:40 requires an OpenSpec proposal + a dependency record for ANY architecture_ref change, even though this bump is non-normative for the consumer (the general OpenSpec tiering would treat a dependency bump as Tier 1). Non-blocking in practice — the upstream v0.3.0 tag already exists and TruPryce absorbs it same-PR (TruPryce/trupryce#64). validate-diagrams no-ops for trupryce (zero tracked .drawio/.svg). Flips to resolved when TruPryce/trupryce#64 and this record both merge.
---

# Dependency: trupryce depends on security-first-platform-architecture — pin to `v0.3.0`

## What the dependency is

TruPryce tracks the architecture repo at an explicit pinned `architecture_ref` in its
[`security-first-adoption.md`](https://github.com/TruPryce/trupryce/blob/main/security-first-adoption.md).
This record is the governance trail (required by TruPryce's `AGENTS.md:40`) for moving that
pin from `v0.2.0` to `v0.3.0`. Upstream must have tagged `v0.3.0` (done); downstream absorbs
the ref in `security-first-adoption.md` and its three reusable-workflow callers.

## Upstream artifact

The architecture repo at tag `v0.3.0`. The `v0.2.0..v0.3.0` delta is additive and
non-normative for a consumer with no committed diagrams: diagram archetype templates,
`standards/diagramming-conventions.md`, and a `validate-diagrams` step added to the
`docs-healthcheck` reusable workflow (which no-ops when there is no `docs/diagrams/`). The
eight-layer control model, the `internal-identity-envelope` contract, the ADRs, and the
deployment-profile docs are unchanged (byte-identical). Driven by the OpenSpec proposal
`trupryce:openspec/proposals/2026-07-05-architecture-ref-v0.3.0-pin/`.

## Downstream impact

TruPryce sets `architecture_ref: v0.3.0` and updates the three
`.github/workflows/*healthcheck*` callers (`@v0.3.0` + `architecture_ref:` inputs). No new
deviations, no runtime change, `pending_openspec_changes` stays empty. CI runs green at
`@v0.3.0` — the new `validate-diagrams` step no-ops because TruPryce tracks zero
`.drawio`/`.svg`. Absorbed in TruPryce/trupryce#64.
