# Multi-Tenancy

Tenant isolation is **structural**, not advisory. It is enforced by data partitioning, policy scoping, and routing — not by a single application-level `WHERE tenant_id = …` clause.

## What "tenant" means here

A **tenant** is the unit of isolation: a customer account, an organization, a product partition, or any other scope that must not leak data into another. Every L7 resource has exactly one tenant (or, rarely, is explicitly cross-tenant with elevated controls).

## Defense in depth

Each layer contributes:

| Layer | Tenant control |
|---|---|
| L2 — Edge gateway | Route segmentation when tenants have separate subdomains / API paths |
| L3 — Identity | Tenant claim on the principal (`tenant` claim on issued tokens) |
| L4 — Authorization | Policy decisions scoped to the principal's tenant; cross-tenant relationships modeled explicitly |
| L5 — Operational guardrails | Per-tenant rate limits and quotas |
| L6 — Orchestrator | `tenant` claim on the internal envelope; cross-tenant calls require explicit re-authorization |
| L7 — Service | Tenant-scoped queries enforced at the data boundary; tenant-aware caches |

A failure in one layer (e.g., bug in a service-level query) does not produce a cross-tenant leak because L4 + L6 also constrain the request.

## Patterns

### Pattern A — One database per tenant
- Strongest isolation; highest operational cost.
- Use for regulated tenants, sovereignty, or extreme blast-radius concerns.

### Pattern B — Shared database, partitioned by tenant
- Tenant column on every row; tenant-scoped queries enforced by an ORM layer or row-level security.
- Standard for most product tenants. Combine with L4 and envelope-based scoping.

### Pattern C — Shared database, logical tenant per schema
- Schema-per-tenant in the same database.
- Trade-off between A and B; useful when tenants need slightly different schemas.

Profiles do not dictate which pattern. The architecture requires only that whichever pattern is chosen is **enforced structurally** and **verified by tests**.

## Cross-tenant operations

Cross-tenant work (analytics, support tooling, platform-wide automations) must:

1. Use a principal explicitly authorized for cross-tenant access (typically a service or platform agent).
2. Be audited as cross-tenant with both source and target tenants recorded.
3. Be rate-limited and observable separately from per-tenant traffic.

## Agents and tenancy

Agents are clients (see [`agent-as-client-model.md`](agent-as-client-model.md)). An agent's tenant scope is the **intersection** of:

- the tenant the agent is provisioned for, and
- the tenant of its `actor` (when acting on behalf of a human).

An agent acting on behalf of a user in tenant *T1* cannot access tenant *T2* data, even if the agent has a broader policy scope.

## What this is not

- Not a recommendation for which database engine to use.
- Not a recommendation for whether to use row-level security vs ORM filters — that's a profile / product decision.
- Not optional in any profile.
