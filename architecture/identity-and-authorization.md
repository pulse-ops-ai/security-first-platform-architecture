# Identity and Authorization

Identity and authorization are **separate layers** with separate stores, separate change cadences, and separate failure modes.

## Identity (Layer 3)

**Question answered.** Who is the caller?

**Responsibilities.**

- Authenticate users (interactive flows, SSO, MFA).
- Authenticate services and agents (client credentials, mTLS, workload identity).
- Issue short-lived tokens that downstream layers can verify offline.
- Federate to external identity providers when applicable.

**Outputs.** A verified principal: a stable subject ID, the authentication context (factors, time, source), and any claims the IdP attached. Tokens are signed and have a small TTL.

**Concrete implementations.** See [`profiles/`](profiles/).

## Authorization (Layer 4)

**Question answered.** Can this principal perform this action on this resource?

**Responsibilities.**

- Maintain the policy model (RBAC, ReBAC, ABAC, or a hybrid).
- Make decisions at request time given (principal, action, resource, context).
- Be queryable both inline (per-request) and out-of-band (admin tooling, audits).

**Outputs.** A `permit` / `deny` decision plus the obligations and supporting claims used to reach it.

**Concrete implementations.** See [`profiles/`](profiles/).

## Why they are separate

| Concern | Identity | Authorization |
|---|---|---|
| Who | yes | indirectly (via principal ID) |
| What permissions exist | no | yes |
| Change cadence | slow (identity model is stable) | fast (permissions evolve daily) |
| Operator | identity / platform team | application + platform team |
| Failure mode | login outage | feature inaccessible, but identity intact |

Collapsing them means every permission change requires touching the identity issuer and every identity change risks corrupting the permission model.

## Token flow

1. Client (user, service, or agent) authenticates with L3 → receives a signed access token.
2. Client presents the token at L2 → L2 routes the request, L3 verifies signature + expiry.
3. L4 receives `(principal, action, resource, context)` and returns a decision.
4. L6 (orchestrator/BFF) wraps the request in a signed **internal identity envelope** (see [`internal-identity-envelope.md`](internal-identity-envelope.md)) carrying the principal, the authorization decision, the request context, and a short TTL.
5. L7 services verify the envelope's signature and apply per-service checks (e.g., tenant scoping).

## Rules

- L3 tokens **never** convey fine-grained permissions. Use them for identity; use L4 for permissions.
- L4 decisions **never** depend on network position.
- The internal envelope **never** crosses Z1 (the edge boundary). External callers re-authenticate.
- Token TTLs are short. Refresh is L3's responsibility.
