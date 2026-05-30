---
# Dependency record — required schema.
#
# Every field is REQUIRED. Leave a field as "n/a" if it truly does not
# apply; do not omit the key. Validators check field presence, not values.

dependency_id:                DEP-2026-05-24-001
title:                        platform-edge initial adoption of security-first platform architecture (L1–L5 self-hosted-vps)
upstream_repo:                security-first-platform-architecture
upstream_ref:                 v0.2.0
upstream_ref_kind:            tag
upstream_artifact:            standards/repo-contract.md
downstream_repo:              platform-edge
downstream_artifact:          security-first-adoption.md
dependency_type:              contract
impact_tier:                  2
status:                       resolved
blocking_direction:           blocks-downstream
required_by:                  2026-06-23
deprecation_window:           n/a
coordinated_landing_order:    upstream-first
owner:                        "@mikegtech"
opened_date:                  2026-05-24
resolved_date:                2026-05-29
related_openspec_proposal:    n/a
notes:                        First fully schema-conformant dependency record in this ledger (the trupryce record is thin-prose and known to need backfill — tracked separately). Scope is strict L1–L5 of the self-hosted-vps profile; platform-edge ships no L6 (per architecture/profiles/self-hosted-vps.md §L6 — Orchestrator/BFF is consumer-owned).
---

# Dependency: platform-edge depends on security-first-platform-architecture — initial adoption (L1–L5)

## What the dependency is

`platform-edge` is a new sibling consuming repo that adopts the security-first platform architecture at tag `v0.2.0` (originally pinned at `v0.1.0`, bumped to `v0.1.1` after the consumer-mode hotfix, then to `v0.2.0` for the enterprise diagramming kit; see §Ref-bump history) and implements the **L1–L5 control layers** of the **self-hosted-vps profile** as a shared edge for the workspace (public Kong gateway, internal Traefik router, Keycloak identity verification at the edge, OpenFGA as the policy decision point, Kong-plugin operational guardrails). It routes inbound traffic — human and agent alike — to per-team orchestrators (L6), which **platform-edge does not own**. The dependency captures `platform-edge`'s commitment to the architecture's Universal Floor plus the per-layer contracts at L1–L5 defined in `architecture/control-layers.md` and instantiated in `architecture/profiles/self-hosted-vps.md`.

## Upstream artifact

The dependency targets the contract surface at `v0.2.0`. Specifically:

- `standards/repo-contract.md` — Universal Floor + Vendor-Specific Adapters (the file recorded in `upstream_artifact:`).
- `architecture/profiles/self-hosted-vps.md` — the L1–L5 contract `platform-edge` is implementing (Kong as the public L2 + L3 verifier; Traefik as the internal east-west router; OpenFGA at L4; Kong plugins for L5 guardrails).
- `architecture/internal-identity-envelope.md` and [`ADR-0003`](../../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md) — the envelope contract that `platform-edge` plumbs inputs *for* but does not issue (envelope issuance is L6, which is consumer-owned in this profile).
- `architecture/agent-as-client-model.md` and [`ADR-0002`](../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md) — the agents-as-clients rule the step-6 lockdown PR will assert.
- `.github/workflows/{repo-healthcheck,docs-healthcheck,pre-commit}.yml` — the reusable workflows `platform-edge`'s thin callers invoke, now pinned at `@v0.2.0` after the repin (the consumer-mode hotfix that first made these work shipped in v0.1.1; v0.1.0's reusable workflows were broken for consumer-mode invocations).

No architecture-side OpenSpec proposal is driving this dependency (`related_openspec_proposal: n/a`). The consumer is the initiator; the upstream contract was finalized at `v0.1.0` independently and is reachable at that ref.

## Downstream impact

A new repo `platform-edge` will be created at the sibling-clone location (`~/work/security-first-platform/platform-edge/`) by copying [`templates/consuming-repo/`](../../templates/consuming-repo/) and substituting `__ARCHITECTURE_REF__` → `v0.1.1`. It will ship:

- The Universal Floor (`README.md`, `AGENTS.md`, `LICENSE`, `docs/INDEX.md`, `security-first-adoption.md` populated against this dependency).
- Vendor-Specific Adapters as elected (`CLAUDE.md` + `.claude/` if the team uses Claude Code).
- Consumer-template CI baseline (three thin-caller workflows at `@v0.1.1`, pre-commit config, secrets baseline, CODEOWNERS).
- A 6-step L1–L5 rollout arc, one control layer per governed PR:
  1. **L1+L2 pass-through** (Tier 1) — Kong + Traefik + stub; no Keycloak, no OpenFGA, no Redis, no cloudflared.
  2. **L3 Keycloak identity at the edge** (Tier 2) — Kong `jwt` plugin against Keycloak JWKS.
  3. **L4 OpenFGA audit-only** (Tier 2) — coarse-grained PDP, decisions logged, never enforced.
  4. **L4→L6 envelope-input plumbing** (Tier 2) — Kong forwards principal claims + `authz_decision_id`; Traefik enables the existing `require-envelope` presence-only middleware. `platform-edge` issues no envelopes; the schema is owned by ADR-0003.
  5. **L4 enforced** (Tier 2 with coordinated landing) — flip audit-only → fail-closed.
  6. **Agents-as-clients audit + lockdown** (Tier 2) — assert no back-channel, verify `principal_type=agent` is set on agent calls, verify L5 limits fire per `principal_type`.

Estimated effort: ~6 governed PRs over four–six weeks. No code changes required in the architecture repo to satisfy this dependency — `v0.1.1` already ships everything needed (and fixes the consumer-mode reusable-workflow bug that briefly blocked `platform-edge` against `v0.1.0`).

## Unblock criteria

The dependency moves to `resolved` when ALL of:

- [x] Upstream artifact is merged at the ref recorded in `upstream_ref` *(satisfied — `v0.2.0` tagged at `25a3724` on `main`; the record has been bumped `v0.1.0` → `v0.1.1` → `v0.2.0`, each ref merged before the corresponding downstream action — see §Ref-bump history)*.
- [x] Downstream integration is merged (or, for `architecture-complete` Tier 2 proposals, downstream has acknowledged in their adoption record) — **defined here as the step-1 pass-through PR in `platform-edge` merging** *(satisfied — `platform-edge`'s step-1 L1+L2 pass-through PR merged; the consumer has since shipped the observability overlay, the `v0.2.0` repin, and the diagram visual refresh on top)*.
- [x] Downstream `security-first-adoption.md` is populated with `architecture_ref: v0.2.0` and validated by `repo-healthcheck` *(satisfied — adoption record pins `v0.2.0`, `deviations: []`, green on consumer-mode CI)*.
- [x] No ADR linked from this record (initial adoption uses existing ADRs unchanged; not applicable).

All four gates are now met, so this record is **resolved** (`resolved_date: 2026-05-29`) per the resolution plan in §Coordinated landing step 5 — the same small-follow-up-PR pattern as PR #16 for trupryce. The record's scope was the L1–L5 *contract adoption*, gated on step-1 merging; the remaining L3–L5 rollout steps proceed as `platform-edge`'s own governed PRs and do not re-open this dependency.

## Coordinated landing

`upstream-first` — the upstream artifact at the current `upstream_ref` (`v0.2.0`) is already merged on `main` of `security-first-platform-architecture`. Originally this record pinned `v0.1.0` (which predated the record); it was bumped to `v0.1.1` after `platform-edge`'s first consumer-mode CI surfaced the reusable-workflow hotfix need, then to `v0.2.0` when the consumer repinned for the enterprise diagramming kit — full audit trail in §Ref-bump history. Either way, there is no race, no simultaneous-PR ceremony, no deprecation window: the upstream side of the dependency was already done before each downstream action.

1. **Upstream (originally)** — `v0.1.0` tagged 2026-05-24 (record's original pin; still reachable on `main`).
2. **Dependency record opened** — `DEP-2026-05-24-001` landed in `portfolio/dependencies/` in PR #18.
3. **Upstream (`v0.1.1`)** — `v0.1.1` tagged 2026-05-28, bundling the consumer-mode hotfix (PR #20) and the diagramming-foundation surface (PR #19). Record's `upstream_ref` bumped from `v0.1.0` → `v0.1.1` in PR #21.
4. **Downstream** — `platform-edge` opened its step-1 pass-through PR pinning `architecture_ref: v0.1.1` and citing `DEP-2026-05-24-001` in its `cross_repo_dependencies:` section; step-1 merged.
5. **Upstream (`v0.2.0`)** — `v0.2.0` tagged 2026-05-29 at `25a3724`, bundling the enterprise diagramming kit (PR #22 Phase A+B, PR #23 Phase C, PR #24 housekeeping). `platform-edge` repinned `v0.1.1` → `v0.2.0` in its PR #4. Record's `upstream_ref` bumped from `v0.1.1` → `v0.2.0` in this PR.
6. **Resolution** — step-1 has merged and `platform-edge`'s adoption record is populated and validated at `v0.2.0`, so this record's `status:` is now `resolved` with `resolved_date: 2026-05-29` (same small-follow-up-PR pattern as PR #16 for trupryce).

Owner on the platform-edge side: `@mikegtech`. Owner on the architecture-repo side: `@mikegtech` (platform team).

## Deprecation window

`n/a` — additive change. No old pattern is being superseded by this dependency; nothing in `security-first-platform-architecture` is changing. `platform-edge` is starting from zero against the existing `v0.1.1` surface.

## Cross-references

- Related OpenSpec proposal: `n/a` (first adoption; consumer-initiated; no architecture-side proposal triggered this).
- Related ADRs: [`ADR-0001`](../../docs/decisions/ADR-0001-adopt-eight-layer-control-model.md), [`ADR-0002`](../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md), [`ADR-0003`](../../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md) — referenced contract, not modified.
- Related portfolio epic: _none yet_ (a "Platform shared-edge L1–L5" epic could be opened in `portfolio/epics/` later if a second consumer routes through `platform-edge`).
- Consumer adoption record entry: `platform-edge/security-first-adoption.md` (to be populated by the step-1 PR; will list `DEP-2026-05-24-001` under `cross_repo_dependencies:`).
- Architecture-repo release (current pin): [`v0.2.0`](https://github.com/pulse-ops-ai/security-first-platform-architecture/releases/tag/v0.2.0). Originally opened against [`v0.1.0`](https://github.com/pulse-ops-ai/security-first-platform-architecture/releases/tag/v0.1.0), bumped to [`v0.1.1`](https://github.com/pulse-ops-ai/security-first-platform-architecture/releases/tag/v0.1.1) after the hotfix, then `v0.2.0` for the diagramming kit — see §Ref-bump history below.
- Sibling existing adoption record (for reference): the trupryce dependency record at [`2026-05-25-trupryce-depends-on-security-first-platform-architecture-onboarding.md`](2026-05-25-trupryce-depends-on-security-first-platform-architecture-onboarding.md) — note that record is the thin-prose form, not schema-conformant; this `platform-edge` record sets the precedent for future records to follow the documented template.

## Notes

- **Scope is strict L1–L5.** `platform-edge` does not include an L6 (orchestrator/BFF). Per `architecture/profiles/self-hosted-vps.md` §L6 and `infra/profiles/self-hosted-vps/README.md` (which lists L6 as *"Custom service (not in this reference)"*), each consuming team owns its orchestrator and is the *only* component that issues the internal identity envelope. `platform-edge`'s step-4 work is plumbing the envelope **inputs** (Kong header forwarding, Traefik presence check) — not issuing envelopes.
- **`CallerContext` is intentionally absent.** Earlier brief drafts used this term; it is not in any architecture document and has been dropped. Cross-repo vocabulary is "internal identity envelope claims" per ADR-0003. Any implementation-local struct of that name in a consuming team's L6 is fine but lives only inside that team's repo.
- **JWT verification location.** Definitively Kong, per `infra/profiles/self-hosted-vps/kong/kong.example.yml` (`jwt` plugin, L24, with the comment *"L3 identity verification at the edge"*). Traefik's `require-envelope` middleware (`infra/profiles/self-hosted-vps/traefik/dynamic.example.yml:11`) is presence-only — *"Real verification happens in the service itself."* This is settled; the step arc reflects it.
- **Schema conformance.** This record is the first in the ledger authored against the full schema in [`../../templates/dependency-record/dependency-template.md`](../../templates/dependency-record/dependency-template.md). All 20 required frontmatter fields and all 7 prose sections are populated. A separate Tier-2 follow-up will either (a) backfill the trupryce record into the same schema and add a CI validator, or (b) revise the template to match a lighter form — pending team decision. Either way, `platform-edge` sets the right precedent now.

## Ref-bump history

| Date | `upstream_ref` | Reason |
|---|---|---|
| 2026-05-24 | `v0.1.0` | Record opened. `v0.1.0` was the latest architecture-repo tag at the time and ships the full universal-floor + self-hosted-vps L1–L5 contract surface. |
| 2026-05-28 | `v0.1.1` | Bumped after `platform-edge`'s first consumer-mode CI surfaced the reusable-workflow event-name guard bug (the `if: github.event_name == 'workflow_call'` gate is always false in reusable workflows). `v0.1.1` bundles the hotfix (PR #20) **and** the diagramming-foundation surface from PR #19 (additive: visual-vocabulary standard + `drawio`/`mermaid-diagram` skills), so `platform-edge` only has to repin once. |
| 2026-05-29 | `v0.2.0` | Bumped after `platform-edge` repinned `v0.1.1` → `v0.2.0` (its PR #4) to adopt the enterprise diagramming kit: PR #22 (Phase A+B — contrast floor, paired fills, connectors, archetypes, C4 palette), PR #23 (Phase C — workspace style library + canonical eight-layer reference), PR #24 (housekeeping — wording fix + drawio `--embed-svg-fonts false` skill recommendation), tagged `v0.2.0` at `25a3724`. Strictly additive; no L1–L5 contract surface changed, so `platform-edge`'s implementation is unaffected. This record resolved on the same date — see §Unblock criteria. |

Future bumps will be appended to this table rather than rewriting it — the audit trail matters when reconstructing why a consumer was at a given pin on a given date.
