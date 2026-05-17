# Internal Identity Envelope

> See [`ADR-0003`](../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md) for the trade-off record — why a signed envelope and not re-called L4, mesh-only identity, or forwarded L3 tokens.

The **internal identity envelope** is a signed, short-lived assertion that carries the verified principal, the authorization decision, and request context across **Zone 4** (internal trusted services). It is the mechanism by which services avoid network-based trust.

This is a **pattern**, not a product. Concrete implementations may use JWS/JOSE, PASETO, biscuit, or platform-native signed tokens.

## Why it exists

Services in Z4 cannot trust:

- the network they sit on,
- the hostname of the caller,
- a mesh-only identity (which proves *which workload* called, not *which end-user / agent* originated the call).

They need a verifiable assertion that:

> "This request originated from principal *P*, was authorized at L4 with decision *D*, in tenant *T*, at time *T0*, expiring at *T1*."

The envelope provides exactly that.

## Required claims

| Claim | Description |
|---|---|
| `sub` | Stable principal ID from L3 |
| `principal_type` | `user`, `service`, or `agent` |
| `tenant` | Tenant ID (if multi-tenant; see [`multi-tenancy.md`](multi-tenancy.md)) |
| `actor` | If the call is on-behalf-of, the original actor |
| `authz_decision_id` | L4 decision reference |
| `iss` | The L6 orchestrator that issued the envelope |
| `aud` | The intended service or set of services |
| `iat` | Issued-at |
| `exp` | Expiry (seconds, not hours) |
| `jti` | Unique envelope ID for audit and replay protection |
| `request_id` | Correlates with observability logs |

Optional claims may include obligation hints, scope, original L3 token reference, and source context.

## Issuance rules

- Only **L6 (orchestrator/BFF)** issues envelopes.
- An envelope **never crosses the edge** (Z1 boundary). External callers always re-authenticate.
- Envelopes are signed with a key that L7 services can verify but not forge.
- Key rotation is automated and routine.
- Envelopes have **short TTLs** (seconds to a few minutes).

## Verification rules

- Every L7 service verifies signature, audience, expiry, and replay (`jti`).
- Services do **not** re-call L4 by default; they trust the embedded decision plus their own per-service checks. (Re-calling L4 for high-risk operations is fine.)
- Services apply tenant scoping using `tenant` and reject envelopes lacking expected claims.

## Profile mappings

Concrete implementations of envelope format, key storage, and key rotation live in [`profiles/`](profiles/). The envelope schema and verification rules are identical across profiles.

## What this is not

- **Not an L3 token.** L3 tokens are presented by external callers. Envelopes are issued internally based on those tokens.
- **Not the only authorization signal.** L7 services may add additional checks (e.g., per-resource ACLs).
- **Not optional.** A service in Z4 without envelope verification is a security gap.
