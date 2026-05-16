# ADR-0001: Adopt the eight-layer control model

- **Status:** accepted
- **Date:** 2026-05-16
- **Authors:** @mike (retroactive capture of decision embedded in PR-1)
- **Related:** [`architecture/control-layers.md`](../../architecture/control-layers.md), [`architecture/principles.md`](../../architecture/principles.md), [`architecture/reference-topology.md`](../../architecture/reference-topology.md), PR #1

## Context

A reusable security-first platform architecture must support multiple deployment profiles (self-hosted VPS, AWS-managed, hybrid tailnet, future Azure/GCP) without being rebuilt each time the vendor stack changes. The dominant failure mode in the industry is the *collapsed-concern platform*: a single gateway does authentication, authorization, routing, rate-limiting, and observability; a single service does business logic, tenant isolation, and audit. When the team outgrows one vendor or needs to add a new deployment target, the platform must be reconstructed.

PR-1 needed to choose a layering model before any other architectural decision could be expressed. The model affects every downstream choice: how profiles are written, what counts as "alignment" for a consuming repo, what an ADR can validly modify, what the OpenSpec policy classifies as Tier 3.

This ADR retroactively captures the decision PR-1 made implicitly so future readers and consumers can cite it.

## Decision

We adopt an **eight-layer control model**:

```
L1. Network reachability
L2. Edge gateway / routing
L3. Identity
L4. Authorization
L5. Operational guardrails
L6. Orchestrator / BFF
L7. Service-level enforcement
L8. Semantic / agent reasoning
```

Each layer has a single responsibility and a contract with its neighbors. Profiles map concrete vendors to these layers; the layers themselves are constant. A profile that cannot satisfy a layer's contract natively must document a [compensating control](../../architecture/deployment-profiles.md#compensating-controls), not weaken the contract.

The model is normative: every consuming repo's `security-first-adoption.md` records which of the eight layers it implements, consumes from elsewhere, or marks `n/a`. Any change to the model itself is Tier 3 per [`team-os/openspec-policy.md`](../../team-os/openspec-policy.md) and requires this ADR to be superseded.

## Consequences

- **Positive.** Vendor swap is layer-by-layer rather than platform-wide — a consumer can move from self-hosted Keycloak to AWS Cognito at L3 without touching L4-L7. The contract surface for consumer alignment is bounded and reviewable. New deployment profiles add files under `architecture/profiles/` without changing the architecture. Cross-team conversations have a shared vocabulary (`L4 fails closed`, `L6 issues the envelope`).
- **Negative.** More conceptual surface area than a 3- or 4-layer model. New contributors must learn eight responsibilities and their contracts before being effective. Some real-world components naturally span multiple layers (e.g., an edge gateway that also does rate-limiting straddles L2 and L5); the model handles this by declaring which contracts the component satisfies, not by forcing a 1:1 layer-to-component mapping.
- **Neutral.** Eight is a working number, not a magic one — it's the smallest count we found that cleanly separated the concerns we cared about (network, edge, identity, authorization, guardrails, orchestration, service, agent). If a future Tier 3 OpenSpec demonstrates a seven-layer or nine-layer model fits better, that's a supersede candidate, not a violation.

## Alternatives considered

- **Three-layer model (network / service / data).** Considered because it's the conventional "perimeter" split that teams arrive at organically. Rejected because it collapses authentication, authorization, and operational guardrails into "service," which is exactly the failure mode this architecture exists to avoid.
- **OWASP-style four-layer model (presentation / business / data / cross-cutting).** Considered because it's well-known and well-documented. Rejected because it's biased toward request-response web apps and doesn't naturally accommodate agentic systems, internal-service-to-service trust, or the explicit separation of identity and authorization.
- **No fixed model — let each profile decide.** Considered for maximum flexibility. Rejected because it would make cross-repo alignment impossible: every consuming repo would be aligning with a different mental model. The whole point of the architecture is to give consumers a shared contract surface.
- **Five-layer model (network / edge / identity-and-authz / service / data).** Considered. Rejected because collapsing identity and authorization into one layer is the same anti-pattern as the three-layer model — they have different change cadences, different stores, different operators. Forcing them into one layer would make the standards harder to enforce.

## References

- [`architecture/control-layers.md`](../../architecture/control-layers.md) — the canonical layer-by-layer spec
- [`architecture/principles.md`](../../architecture/principles.md) — principles each layer must satisfy
- [`architecture/reference-topology.md`](../../architecture/reference-topology.md) — abstract topology diagram
- [`architecture/profiles/`](../../architecture/profiles/) — concrete vendor mappings per profile
- Related ADRs: [ADR-0002](ADR-0002-agents-are-clients-not-insiders.md) (agent-as-client rule applied to L8), [ADR-0003](ADR-0003-internal-identity-envelope-as-z4-trust.md) (envelope as the Z4 trust mechanism between L6 and L7)
- PR #1 — initial scaffold; the layering was a design decision embedded in the initial architecture docs without an accompanying ADR. This ADR closes that gap retroactively.

---

**Note.** Once status moves to `accepted`, this file is **immutable**. Reverse the decision by writing a new ADR that supersedes this one.
