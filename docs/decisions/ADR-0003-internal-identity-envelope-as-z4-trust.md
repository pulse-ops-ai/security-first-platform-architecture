# ADR-0003: Internal identity envelope is the Z4 trust mechanism

- **Status:** accepted
- **Date:** 2026-05-16
- **Authors:** @mike (retroactive capture of decision embedded in PR-1)
- **Related:** [`architecture/internal-identity-envelope.md`](../../architecture/internal-identity-envelope.md), [`architecture/security-boundaries.md`](../../architecture/security-boundaries.md), [ADR-0001](ADR-0001-adopt-eight-layer-control-model.md), [ADR-0002](ADR-0002-agents-are-clients-not-insiders.md), PR #1

## Context

[ADR-0001](ADR-0001-adopt-eight-layer-control-model.md) separates the platform into eight control layers. Z4 is the trust zone inside the orchestrator/BFF (L6) and service-level enforcement (L7) — the layers behind the edge. Services in Z4 cannot trust:

- the network they sit on (a VPC, tailnet, or service mesh confers no identity by [ADR-0002](ADR-0002-agents-are-clients-not-insiders.md))
- the hostname of the caller
- a mesh-only mTLS peer cert (proves which *workload* called, not which *end-user or agent* originated the call)
- the original L3 token (issued for external callers; L7 services should not re-bear external credentials, and the token's audience is the edge, not internal services)

They need a verifiable assertion that "this request originated from principal *P*, of principal_type *T*, with actor *A* (if on-behalf-of), in tenant *N*, was authorized at L4 with decision *D*, and is valid until time *X*."

Before this decision, real-world platforms typically pick one of these failure paths: re-call L4 from every service (cost + latency), pass the original L3 token internally (over-bearing scope, audience confusion), or trust the network (the anti-pattern this entire architecture exists to prevent).

The architecture needs a single, normative mechanism for L6→L7 trust that doesn't reduce to any of those failure modes.

## Decision

We adopt the **internal identity envelope** as the Z4 trust mechanism:

- The envelope is a short-lived, signed assertion carrying: `sub`, `principal_type`, `tenant`, `actor` (if on-behalf-of), `authz_decision_id`, `iss`, `aud`, `iat`, `exp`, `jti`, `request_id`.
- The envelope format is **vendor-neutral**: the canonical pattern is JWS/JOSE, but profiles may use PASETO, biscuit, or platform-native signed tokens. The *claims* and *verification rules* are constant; the *format* varies per profile.
- Only **L6 (orchestrator/BFF)** issues envelopes.
- Every L7 service verifies signature, audience, expiry, and replay (`jti`) on **every** request — not once at the edge of Z4.
- Envelopes **never cross Z1** (the edge). External callers always re-authenticate. The envelope is internal-only.
- TTLs are short (seconds to a few minutes). Key rotation is automated and routine.
- The envelope is **not** an L3 token. L3 tokens are external; envelopes are internal. The two never mix.

## Consequences

- **Positive.** Clean Z4 trust model: L7 services have a single contract (verify the envelope) and a single source of identity. No network-trust assumptions. On-behalf-of accounting is correct because `actor` rides in the envelope. Re-calls to L4 from L7 are *allowed but not required* — services trust the embedded decision plus their own per-service checks, and only re-call L4 for high-risk operations (a per-service choice, not a platform-wide trade-off).
- **Negative.** Every internal service must implement envelope verification. The implementation is small but it's per-service work, and it must fail closed. Key rotation requires coordination across all L7 services. Short TTLs mean more crypto operations per request, but the cleaner replay semantics are worth it.
- **Neutral.** Format choice is per-profile. Self-hosted profiles can pick JWS with Keycloak-rotated keys; AWS profiles can pick JWS with KMS-managed keys; future profiles can pick something different entirely. The architecture only requires the *claims* and *verification rules* be uniform — which the standards enforce.

## Alternatives considered

- **Re-call L4 from every L7 service.** Considered because it has the strongest "no implicit trust" property. Rejected for cost and latency: a single user request often fans out to 5-15 service calls, and re-calling L4 each time inflates latency unacceptably. The envelope's `authz_decision_id` lets services trace back to the L4 decision when they need to, without paying for the call inline.
- **Token forwarding (pass the original L3 token internally).** Considered for its simplicity. Rejected because L3 tokens are minted for external audiences with external scope; reusing them internally creates audience confusion (the token's `aud` claim is the edge, not the service), increases the blast radius of any token leak, and conflates external user-identity with internal service-to-service-identity.
- **Service-mesh-only identity (mTLS peer certificate).** Considered for service-to-service paths. Rejected by the reasoning in [ADR-0002](ADR-0002-agents-are-clients-not-insiders.md): mesh identity proves the workload, not the end-user or agent. Mesh can be a useful *additional* signal at L1/L2 for network admission, but it must not be the authentication evidence at Z4.
- **Bearer tokens minted per call by L6, with no shared envelope schema.** Considered as a lower-discipline middle ground. Rejected because it leaves the claim shape implicit, makes audit cross-cutting work, and prevents the architecture from being implementation-neutral (every profile would have a different schema).
- **No envelope; rely on each profile's native pattern.** Considered for maximum profile flexibility. Rejected because the lack of a normative mechanism is exactly what makes platforms collapse when they change profiles. The envelope is the architecture's commitment to a stable internal-trust contract.

## References

- [`architecture/internal-identity-envelope.md`](../../architecture/internal-identity-envelope.md) — claim spec, issuance rules, verification rules
- [`architecture/security-boundaries.md`](../../architecture/security-boundaries.md) — Z0→Z4 crossings; the envelope is the Z3→Z4 evidence
- [`architecture/identity-and-authorization.md`](../../architecture/identity-and-authorization.md) — how L3 tokens differ from envelopes
- [`infra/profiles/self-hosted-vps/keycloak/realm-export.example.json`](../../infra/profiles/self-hosted-vps/keycloak/realm-export.example.json) — example realm with envelope-signing key references
- Related ADRs: [ADR-0001](ADR-0001-adopt-eight-layer-control-model.md), [ADR-0002](ADR-0002-agents-are-clients-not-insiders.md)
- PR #1 — initial scaffold

---

**Note.** Once status moves to `accepted`, this file is **immutable**. Reverse the decision by writing a new ADR that supersedes this one.
