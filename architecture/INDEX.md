# architecture/ — Index

This is the implementation-neutral reference architecture. Vendor mappings live under [`profiles/`](profiles/).

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
