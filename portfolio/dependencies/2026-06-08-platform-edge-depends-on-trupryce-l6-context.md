---
# Dependency record — required schema.
#
# Every field is REQUIRED. Leave a field as "n/a" if it truly does not
# apply; do not omit the key. Validators check field presence, not values.

dependency_id:                DEP-2026-06-08-001
title:                        platform-edge depends on trupryce L6 for L4→L6 context forwarding + the api.trupryce.ai origin
upstream_repo:                trupryce
upstream_ref:                 main
upstream_ref_kind:            branch
upstream_artifact:            TruPryce L6 orchestrator — accepts+logs the x-platform-edge-* context headers; exposes a private api.trupryce.ai origin; remains the sole Z4 envelope minter
downstream_repo:              platform-edge
downstream_artifact:          infra/profiles/self-hosted-vps/ (OpenFGA audit-only + authz-audit-sidecar + spoof-strip + context forwarding); openspec/proposals/2026-06-08-step-3-4-openfga-audit-and-l6-context/
dependency_type:              contract
impact_tier:                  2
status:                       resolved
blocking_direction:           blocks-downstream
required_by:                  2026-08-31
deprecation_window:           n/a
coordinated_landing_order:    downstream-first
owner:                        "@mikegtech"
opened_date:                  2026-06-08
resolved_date:                2026-06-14
related_openspec_proposal:    platform-edge:openspec/proposals/2026-06-08-step-3-4-openfga-audit-and-l6-context/proposal.md
notes:                        Audit-only first — platform-edge asks OpenFGA on every request, logs the decision, forwards L3+L4 context, but ENFORCES NOTHING and mints NO Z4 envelope. TruPryce orchestrator remains the sole Z4 minter; TruPryce provider enforcement stays shadow until its own I7/I8 gates. The x-platform-edge-* header contract is a CONSUMER-LOCAL platform-edge<->trupryce contract this round (not yet a profile-level architecture standard). Cutover is gated on the TruPryce-owner confirmation below.
---

# Dependency: platform-edge depends on trupryce — L4→L6 context forwarding + `api.trupryce.ai` origin

## What the dependency is

`platform-edge`'s step-3/4 work adds OpenFGA **audit-only** authorization at the edge and forwards verified **L3 + L4 context** to TruPryce's **L6 orchestrator**, ahead of moving real `api.trupryce.ai` traffic through the edge. This creates a bidirectional-but-downstream-gated dependency: `platform-edge` needs TruPryce to (a) expose a **private origin** for the `api.trupryce.ai` upstream, and (b) **accept and log** the `x-platform-edge-*` context headers; TruPryce needs `platform-edge` to deliver trusted, spoof-protected context. `platform-edge` **mints no Z4 envelope** — TruPryce's orchestrator remains the sole minter.

## Upstream artifact

- **Private `api.trupryce.ai` origin** (`TRUPRYCE_API_UPSTREAM_URL` = a private IP / Tailnet host:port) — **never** the public hostname (that loops back to Kong after cutover). Optional expected upstream `Host` header.
- **L6 acceptance + logging** of the forwarded context headers: `x-request-id`, `x-platform-edge-realm`, `x-platform-edge-principal-sub`, `x-platform-edge-principal-type`, `x-platform-edge-authz-decision-id`, `x-platform-edge-authz-decision`, `x-platform-edge-authz-mode=audit`.
- **Z4 envelope minting stays in the TruPryce orchestrator;** provider enforcement stays **shadow** until TruPryce's own I7/I8 gates.
- Driven by the OpenSpec proposal `platform-edge:openspec/proposals/2026-06-08-step-3-4-openfga-audit-and-l6-context/`.

## Downstream impact

`platform-edge` gains (in the step-3/4 implementation PR, not the proposal PR): an OpenFGA service + platform-edge-owned Postgres + model loader; a first-party `authz-audit-sidecar` (the mainline OpenFGA caller); a Kong spoof-strip + thin sidecar call + trusted context-header set; the `authz_audit` sealed index; and `l4_authorization: n/a → implemented (audit-only)`. No code change is required in TruPryce to satisfy the OpenFGA wiring; the cutover specifically requires TruPryce readiness (the confirmation gate).

## Unblock criteria

The dependency moves to `resolved` when ALL of:

- [x] **TruPryce-owner confirmation gate recorded** (the eight items below) — TruPryce PR #52, 2026-06-13.
- [x] Downstream integration is merged — the platform-edge step-3/4 **audit-only implementation** (PR #16) + the **cutover-route wiring** (the `trupryce-api` route → the private origin).
- [x] Downstream `security-first-adoption.md` updated to `l4_authorization: implemented` (audit-only) — **done 2026-06-14**.
- [x] `api.trupryce.ai` cutover exercised against the **private origin**; TruPryce logs the forwarded context — **done 2026-06-14** (pre-DNS smoke through the edge → `100.117.236.25:8081`; audit-grade three-way `x-request-id` correlation).
- [x] No ADR required (audit-only uses existing v0.3.0 contracts; the `x-platform-edge-*` contract stays consumer-local).

**RESOLVED 2026-06-14.** The 2026-06-14 live pre-DNS smoke passed: platform-edge Tier 1 PASS and **audit-grade three-way `x-request-id` correlation** on RID `cutover-smoke-20260614-213636-listings-v3` — the same RID + `authz_decision_id` join edge `authz_audit`, orchestrator `platform_edge.context`, and provider `envelope.verify` (`result=ok`, `shadow_mode=true`; orchestrator mints the Z4 envelope; providers `ENVELOPE_REQUIRED=false`). The earlier provider-correlation gap (platform-edge **issue #23**) was fixed TruPryce-side (`RequestContext`/`AsyncLocalStorage`) and reverified. `l4_authorization: implemented` (audit-only); evidence in `platform-edge:docs/runbooks/cutover-smoke-evidence-2026-06-14.md`. Public `api.trupryce.ai` DNS go-live is the operator step; **no route in `enforce`** (enforcement = step 5).

### TruPryce-owner confirmation gate

**Gate recorded via TruPryce PR #52 (2026-06-13); item #4 RESOLVED by the 2026-06-14 retest (issue #23 fix).**

1. [x] Private origin URL / upstream target — `TRUPRYCE_API_UPSTREAM_URL=http://100.117.236.25:8081` (private Tailnet origin).
2. [x] Expected upstream `Host` header — **none** (empty → the platform-edge route preserves the inbound `api.trupryce.ai` Host).
3. [x] TruPryce orchestrator accepts + logs `x-platform-edge-*` — TruPryce `PLATFORM_EDGE_CONTEXT_ENABLED=true`; logs `platform_edge.context`.
4. [x] TruPryce correlates `x-request-id` **end to end** — **RESOLVED 2026-06-14.** After the `RequestContext`/`AsyncLocalStorage` fix (platform-edge issue #23), the retest shows the **same `x-request-id`** across edge `authz_audit` + orchestrator `platform_edge.context` + provider `envelope.verify` (RID `cutover-smoke-20260614-213636-listings-v3`) — audit-grade, not timestamp-only.
5. [x] TruPryce understands `authz_decision_id` / `x-platform-edge-authz-decision` is audit-only at first (advisory, not enforcement).
6. [x] Z4 envelope minting stays in the TruPryce orchestrator (platform-edge mints none).
7. [x] TruPryce provider enforcement stays shadow until its own I7/I8 gates — providers `ENVELOPE_REQUIRED=false`.
8. [x] Documented `api.trupryce.ai` rollback path — DNS revert to the existing Cloudflare Tunnel path (platform-edge runbook §Rollback).

## Coordinated landing

`downstream-first` — TruPryce L6 must be ready to **receive and log** the forwarded context (and the private origin must exist) **before** `api.trupryce.ai` DNS points at Kong. The OpenFGA audit-only wiring itself is independent and can land + be proven hermetically first, behind a not-yet-cut hostname.

## Deprecation window

`n/a` — additive. Audit-only enforces nothing and supersedes no existing behavior; nothing in TruPryce changes for the OpenFGA wiring. The cutover is a DNS repoint with a documented rollback.

## Cross-references

- Related OpenSpec proposal: `platform-edge:openspec/proposals/2026-06-08-step-3-4-openfga-audit-and-l6-context/proposal.md`.
- Related ADRs: [`ADR-0003`](../../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md) — only L6 mints the Z4 envelope; the edge forwards inputs (referenced, not modified).
- Runbook: `platform-edge:docs/runbooks/api-trupryce-cutover-l4-audit.md`.
- Consumer adoption record entry: `platform-edge/security-first-adoption.md` → `cross_repo_dependencies[].dependency_id = DEP-2026-06-08-001`.
- Sibling dependency: [`DEP-2026-06-07-001`](2026-06-07-platform-edge-depends-on-infra-auth-keycloak.md) (platform-edge → infra-auth, L3).

## Notes

- **Audit-only, no enforcement, no envelope minting at the edge.** platform-edge asks OpenFGA on every request and logs the decision; the request continues while `AUTHZ_MODE=audit`. Enforcement (a per-route `audit→enforce` flip) is a separate later proposal. TruPryce remains the sole Z4 minter.
- **`x-platform-edge-*` is consumer-local for now.** First consumer of this exact context shape; prove it against real `api.trupryce.ai` traffic before any promotion to a profile-level architecture standard (a future, separate change).
- **OpenFGA datastore is platform-edge-owned** (its own Postgres), not shared with TruPryce's app DB.
