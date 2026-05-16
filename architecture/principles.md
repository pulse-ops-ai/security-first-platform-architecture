# Architecture Principles

Every implementation profile must respect these principles. A change to any of them is an architecture-level change and requires an OpenSpec proposal.

## 1. Security is layered, not centralized

No single component is responsible for all enforcement. Each of the eight control layers contributes specific guarantees. A breach of one layer must not collapse the others.

## 2. Implementation neutrality

The architecture names **roles**, not products. "Edge gateway" is a role; many specific products implement it. The architecture documents the role; [`profiles/`](profiles/) map products to roles.

## 3. Identity is explicit and end-to-end

Every request carries verifiable identity from edge to service. Internal services do not trust IP addresses, hostnames, or service-mesh-only signals as identity. A signed internal envelope (see [`internal-identity-envelope.md`](internal-identity-envelope.md)) carries identity across the platform.

## 4. Authorization is decoupled from identity

Identity answers *who*. Authorization answers *can they?* These are separate layers, separate stores, separate change cadences. Authorization decisions are made by a policy decision point (PDP) — not embedded in services. Concrete PDP technologies are named in [`profiles/`](profiles/).

## 5. Agents are clients

An agent — automated, AI, or human-driven — is an external caller. It authenticates, authorizes, and routes through the same gateway and policy chain as any other client. See [`agent-as-client-model.md`](agent-as-client-model.md).

## 6. Observability is a layer, not a feature

Every layer emits structured logs, traces, and metrics on a common schema. Observability is not optional and not added after the fact.

## 7. Tenant isolation is structural

Multi-tenancy is enforced by data partitioning, policy scoping, and routing — not by a `WHERE tenant_id = …` clause inside application code as the only line of defense.

## 8. Operational guardrails are programmable

Rate limits, circuit breakers, quotas, kill switches, and feature flags belong in a layer separate from business logic, so they can be operated independently.

## 9. Profiles do not break the model

Switching from a self-hosted profile to a cloud-managed profile may change every product in the stack, but it must not require redefining the architecture. If a profile cannot satisfy a layer, the profile is incomplete — not the architecture.

## 10. Context is architecture

Coding agents inherit correctness from structure. Folder layout, indexes, and standards are not cosmetic — they determine how fast and how correctly agents (human or AI) can operate.
