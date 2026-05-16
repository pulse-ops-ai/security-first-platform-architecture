# infra/policies/ — Authorization Policy References

Layer 4 (Authorization) is decoupled from identity and from services. The architecture is neutral about which policy engine you choose; this directory documents how to model authorization for each engine the profiles name.

| Engine | Where it appears | Reference |
|---|---|---|
| **OpenFGA** | self-hosted-vps profile; AWS-managed when relationship-based modeling is needed | [`openfga/`](openfga/) |
| **OPA (Rego)** | AWS-managed when policy-as-code workflows are preferred | [`opa/`](opa/) |
| **Cedar (Verified Permissions)** | AWS-managed when managed PDP is preferred | [`cedar/`](cedar/) |

## The common contract

Whatever the engine, the L4 layer must:

1. Decide `(principal, action, resource, context) → permit | deny + obligations`.
2. Treat the principal type explicitly (`user`, `service`, `agent`) per [`../../architecture/agent-as-client-model.md`](../../architecture/agent-as-client-model.md).
3. Enforce tenant scoping per [`../../architecture/multi-tenancy.md`](../../architecture/multi-tenancy.md).
4. Be queryable both inline (per-request) and out-of-band (admin tooling, audits).
5. Emit decisions to the audit sink per [`../../architecture/observability.md`](../../architecture/observability.md).

A profile is free to **substitute** one engine for another. The architecture contract does not change; only the policy language and runtime do.

## What lives in this directory vs in a solution-infra repo

| In this repo | In a solution-infra repo |
|---|---|
| The reference model for each engine | The actual policies that govern that solution |
| Examples of agent-as-client and tenant relationships | Product-specific resource types and actions |
| Test patterns | Live tests with real tuples and policy fixtures |

Live policies are part of the application's source of truth and ship with the solution, not with the architecture.
