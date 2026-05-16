# architecture/ — Engineering entry point

This is the implementation-neutral reference architecture. Vendor mappings live under [`profiles/`](profiles/). For *why* these specific choices were made, see [`Related decisions`](#related-decisions) at the bottom.

For product-level framing (what this repo promises, who owns it, how consumers adopt), use [`../docs/product/INDEX.md`](../docs/product/INDEX.md).

## Concepts

- [`overview.md`](overview.md) — what this architecture is and what problem it solves
- [`principles.md`](principles.md) — design principles every profile must respect
- [`control-layers.md`](control-layers.md) — the eight-layer control model
- [`reference-topology.md`](reference-topology.md) — abstract topology diagram in text
- [`security-boundaries.md`](security-boundaries.md) — trust zones and crossing rules

## Identity & Authorization

- [`identity-and-authorization.md`](identity-and-authorization.md) — how identity flows
- [`internal-identity-envelope.md`](internal-identity-envelope.md) — signed internal claims (JWS/JOSE pattern, vendor-neutral)
- [`agent-as-client-model.md`](agent-as-client-model.md) — agents are clients, not insiders

## Operations

- [`multi-tenancy.md`](multi-tenancy.md) — tenant isolation patterns
- [`observability.md`](observability.md) — what every layer must emit

## Profiles

- [`deployment-profiles.md`](deployment-profiles.md) — how to use a profile
- [`profiles/`](profiles/) — concrete mappings (self-hosted VPS, AWS-managed, hybrid tailnet)

## Related decisions

The architecture's load-bearing commitments are captured as ADRs. Each is immutable once accepted; reverse via a new ADR that supersedes.

- [`ADR-0001 — Adopt the eight-layer control model`](../docs/decisions/ADR-0001-adopt-eight-layer-control-model.md) — rationale for the eight-layer split and the alternatives that were rejected.
- [`ADR-0002 — Agents are clients, not insiders`](../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md) — why agents traverse the same controls as any other caller.
- [`ADR-0003 — Internal identity envelope is the Z4 trust mechanism`](../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md) — why a signed envelope is the L6→L7 trust contract, not mesh identity or re-called L4.

Full ADR index: [`../docs/decisions/INDEX.md`](../docs/decisions/INDEX.md).
