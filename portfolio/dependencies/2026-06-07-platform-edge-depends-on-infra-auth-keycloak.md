---
# Dependency record — required schema.
#
# Every field is REQUIRED. Leave a field as "n/a" if it truly does not
# apply; do not omit the key. Validators check field presence, not values.

dependency_id:                DEP-2026-06-07-001
title:                        platform-edge depends on infra-auth Keycloak for L3 edge identity verification
upstream_repo:                infra-auth
upstream_ref:                 main
upstream_ref_kind:            branch
upstream_artifact:            Keycloak issuer https://auth.trupryce.ai — per-realm JWKS endpoints + canonical realm list (mainline realm: trupryce-prod)
downstream_repo:              platform-edge
downstream_artifact:          infra/profiles/self-hosted-vps/ (Kong CE jwt plugin + JWKS-sync loader + iss-binding post-function); openspec/proposals/2026-06-07-step-2-l3-keycloak/
dependency_type:              contract
impact_tier:                  2
status:                       open
blocking_direction:           blocks-downstream
required_by:                  2026-07-31
deprecation_window:           n/a
coordinated_landing_order:    upstream-first
owner:                        "@mikegtech"
opened_date:                  2026-06-07
resolved_date:
related_openspec_proposal:    platform-edge:openspec/proposals/2026-06-07-step-2-l3-keycloak/proposal.md
notes:                        infra-auth is an INFRASTRUCTURE repo (self-hosted Keycloak on Azure Container Apps + Cloudflare Tunnel + Postgres-over-Tailscale), NOT an architecture-consuming repo — it has no security-first-adoption.md. The real dependency is on the RUNNING IdP + realm inventory, not a code artifact; hence upstream_ref is the branch, not a tagged release. platform-edge consumes the issuer; it does not run Keycloak.
---

# Dependency: platform-edge depends on infra-auth — Keycloak L3 edge identity

## What the dependency is

`platform-edge`'s step-2 work (L3 identity at the edge) verifies inbound JWTs at the Kong CE edge against signing keys issued by Keycloak. That Keycloak is **not** part of platform-edge: its runtime, datastore, realms, users, and signing keys are owned by **`pulse-ops-ai/infra-auth`** (self-hosted Keycloak on Azure Container Apps, fronted by Cloudflare Tunnel, at `https://auth.trupryce.ai`). platform-edge **consumes** that issuer — it fetches each configured realm's JWKS at bring-up via a sync loader and registers the keys into Kong as `jwt` credentials keyed by `kid`. The dependency is therefore on infra-auth delivering: a stable issuer base URL, reachable per-realm JWKS endpoints, and an authoritative (owner-curated) realm list.

## Upstream artifact

- **Issuer base:** `https://auth.trupryce.ai`.
- **Per-realm JWKS:** `https://auth.trupryce.ai/realms/<realm>/protocol/openid-connect/certs`.
- **Canonical realm list:** owned by infra-auth / the platform owner — **not** discovered from the Keycloak admin API. The step-2 mainline consumes exactly one realm: **`trupryce-prod`**. (`master` is the admin realm and is explicitly excluded; dev/staging/legacy realms are not wired into the production edge. Additional product realms — e.g. a future `findevil-prod` — are created in infra-auth first, then added to platform-edge by config when a route needs them.)
- Driven by the OpenSpec proposal `platform-edge:openspec/proposals/2026-06-07-step-2-l3-keycloak/`.

## Downstream impact

platform-edge gains (in its step-2 implementation PR, not the proposal PR): a `keycloak-jwks-loader` init container, the Kong `jwt` plugin + an `iss`-binding `post-function`, `.env` keys (`KEYCLOAK_BASE_URL`, `KEYCLOAK_REALMS`), and the `l3_identity` adoption flag flipping `n/a → implemented`. No code changes in infra-auth are required to satisfy this dependency — its `trupryce-prod` realm and issuer already exist; this record makes infra-auth availability an explicit, tracked prerequisite for platform-edge's L3 acceptance.

## Unblock criteria

The dependency moves to `resolved` when ALL of:

- [x] Upstream artifact exists at the ref recorded in `upstream_ref` *(satisfied — `trupryce-prod` realm + issuer are live at `https://auth.trupryce.ai`)*.
- [ ] Downstream integration is merged — defined here as the platform-edge **step-2 implementation PR** (loader + `jwt` + `post-function`) merging.
- [ ] Downstream `security-first-adoption.md` updated to `l3_identity: implemented`.
- [ ] No ADR required (initial L3 adoption uses existing v0.3.0 contracts unchanged; not applicable).

## Coordinated landing

`upstream-first` — and in the clean sense: the upstream artifact (the `trupryce-prod` issuer + JWKS) already exists before this record was opened. There is no race. Order:

1. **Upstream** — infra-auth's `trupryce-prod` realm + issuer live (already done).
2. **This record** lands in `portfolio/dependencies/` (companion PR to the platform-edge proposal).
3. **Downstream** — platform-edge accepts its step-2 OpenSpec proposal, then merges the implementation PR consuming `KEYCLOAK_BASE_URL` + `KEYCLOAK_REALMS=trupryce-prod`.
4. **Resolution** — when the implementation PR merges and `l3_identity` flips to `implemented`, this record's `status` → `resolved` and `resolved_date` is filled (small follow-up PR here, same pattern as the platform-edge onboarding record).

Owner on the platform-edge side: `@mikegtech`. Availability/contract owner on the infra-auth side: `@mikegtech`.

## Deprecation window

`n/a` — additive. platform-edge had no L3 before; nothing in infra-auth changes. No coexistence period needed.

## Cross-references

- Related OpenSpec proposal: `platform-edge:openspec/proposals/2026-06-07-step-2-l3-keycloak/proposal.md`.
- Related ADRs: [`ADR-0002`](../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md) — agents authenticate at L3 like any other client (referenced, not modified).
- Related portfolio epic: _none yet_ (a "platform-edge L3–L5 rollout" epic could be opened if a second product realm routes through platform-edge).
- Consumer adoption record entry: `platform-edge/security-first-adoption.md` → `cross_repo_dependencies[].dependency_id = DEP-2026-06-07-001`.
- Sibling onboarding dependency: [`DEP-2026-05-24-001`](2026-05-24-platform-edge-depends-on-security-first-platform-architecture-onboarding.md) (platform-edge → architecture).

## Notes

- **infra-auth is not an architecture-consuming repo.** It is the infrastructure that *owns* the IdP. It has no `security-first-adoption.md` and does not adopt the eight-layer model itself; it is a dependency platform-edge consumes. This record is the workspace's coordination ledger entry for that consumption.
- **Topology note (for architecture-team awareness):** the architecture's reference `infra/profiles/self-hosted-vps/docker-compose.example.yml` bundles a Keycloak service into the self-hosted-vps stack. platform-edge externalizes Keycloak to infra-auth and consumes it. The step-2 OpenSpec proposal flags this for an explicit "refinement vs deviation" ruling; if ruled a deviation, a deviation record + compensating control will be added to platform-edge's adoption record and cross-referenced here.
- **The realm list is owned, not discovered.** A guardrail of the platform-edge loader is that it consumes an owner-curated `KEYCLOAK_REALMS` list, never the full set of realms visible in the Keycloak admin API. Adding a realm is a controlled config change.
