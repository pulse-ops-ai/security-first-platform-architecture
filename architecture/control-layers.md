# The Eight Control Layers

> See [`ADR-0001`](../docs/decisions/ADR-0001-adopt-eight-layer-control-model.md) for the trade-off record — alternatives weighed, why eight and not three / four / five.

A security-first platform separates control into eight layers. Each layer has a single responsibility, a contract with the layers above and below, and an explicit place where each implementation profile must satisfy it.

```
+-------------------------------------------------------------+
| 8. Semantic / agent reasoning   (planning, tools, retrieval) |
+-------------------------------------------------------------+
| 7. Service-level enforcement   (per-service authz, tenancy)  |
+-------------------------------------------------------------+
| 6. Orchestrator / BFF          (workflow, composition)       |
+-------------------------------------------------------------+
| 5. Operational guardrails      (rate limits, quotas, flags)  |
+-------------------------------------------------------------+
| 4. Authorization               (policy decision point)       |
+-------------------------------------------------------------+
| 3. Identity                    (authn, token issuance)       |
+-------------------------------------------------------------+
| 2. Edge gateway / routing      (TLS term, routing, WAF)      |
+-------------------------------------------------------------+
| 1. Network reachability        (who can reach the edge)      |
+-------------------------------------------------------------+
```

## 1. Network reachability

**Responsibility.** Decide who can address the platform at all. Network-layer admission.

**Contract.** Layer 2 receives only traffic that has passed network admission.

## 2. Edge gateway / routing

**Responsibility.** TLS termination, request routing, web application firewall, request shaping. Stable public surface.

**Contract.** Layer 3 receives routed requests with TLS already terminated and basic request shape validated.

## 3. Identity

**Responsibility.** Verify *who* the caller is. Issue tokens. Refresh sessions. Federate identity providers.

**Contract.** Layer 4 receives a verified principal (user, service, agent).

## 4. Authorization

**Responsibility.** Decide *can this principal perform this action on this resource?* — fine-grained, relationship-based, or attribute-based. Decisions are made by a policy decision point (PDP) — not embedded in services.

**Contract.** Layer 5 receives authorized requests with an authorization decision and supporting claims.

## 5. Operational guardrails

**Responsibility.** Rate limits, quotas, circuit breakers, feature flags, kill switches, cost guards. Enforced independently of business logic.

**Contract.** Layer 6 receives requests that are within operational envelope.

## 6. Orchestrator / BFF

**Responsibility.** Compose backend services into use-case-shaped APIs. Translate identity and authorization into the language each downstream service expects. Carry the internal identity envelope.

**Contract.** Layer 7 receives a request with a signed internal identity envelope and a use-case context.

## 7. Service-level enforcement

**Responsibility.** Per-service authorization, tenant isolation at the data boundary, input validation, audit emission.

**Contract.** Layer 8 (when present) receives data already filtered by tenant and policy.

## 8. Semantic / agent reasoning

**Responsibility.** Planning, tool selection, retrieval, and reasoning for agentic workflows. Agents call back into Layer 2 as clients — they do not bypass earlier layers.

**Contract.** Outputs are returned through the same response path; agent-initiated calls re-enter the stack at Layer 1 or 2 like any other client.

## Concrete vendor mappings

Vendor mappings for each layer live in [`profiles/`](profiles/). This file describes roles only.

## Layer crossing rules

- A request **must** traverse layers in order. Layer 4 must not be reached without Layer 3 having succeeded.
- A layer **must not** assume guarantees from a layer it has not seen evidence of (e.g., a service must verify the internal identity envelope, not trust the network).
- Each layer **must** emit observability signals consistent with [`observability.md`](observability.md).
