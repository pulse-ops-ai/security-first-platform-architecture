# Security Boundaries

## Trust zones

The platform defines four trust zones. A request crossing a zone boundary must produce verifiable evidence — never a network assumption.

| Zone | Description | Crossing requires |
|---|---|---|
| **Z0 — Public** | The internet, customer environments, anything the platform does not control. | Network admission (L1) |
| **Z1 — Edge** | TLS-terminated, WAF-protected, routed by the edge gateway. | Routing rule + WAF disposition (L2) |
| **Z2 — Authenticated** | Caller's identity verified. Identity claims attached to request. | Verified token (L3) |
| **Z3 — Authorized** | Caller has explicit permission for this action/resource. | Policy decision (L4) |
| **Z4 — Internal trusted** | Inside the orchestrator/BFF and service mesh, carrying a signed internal envelope. | Verified internal envelope (see [`internal-identity-envelope.md`](internal-identity-envelope.md)) |

## Crossing rules

1. **No skipping zones.** A request cannot enter Z3 without having satisfied Z2.
2. **No network-based trust.** Being inside a VPC, Tailnet, or service mesh is **not** evidence of identity. Identity is evidence of identity.
3. **Evidence is verifiable.** Each crossing produces a claim the next layer can independently verify (signed token, policy decision, signed envelope).
4. **Failed crossings are audited.** Every rejection is observable: which layer rejected, why, with what evidence.

## Common anti-patterns the architecture rejects

- **Implicit trust on private networks.** "It came from our VPC, so it's safe."
- **Identity inside authorization.** Embedding role checks in the token issuer rather than in a policy decision point.
- **Service-to-service trust by hostname or IP.** Services authenticating each other by network identity alone.
- **Agents as insiders.** Allowing an agent runtime to bypass the gateway because "it's part of the platform."

## Where each crossing is enforced

| Crossing | Layer responsible |
|---|---|
| Z0 → Z1 | L1 + L2 (network admission + edge gateway) |
| Z1 → Z2 | L3 (identity issues a verified token) |
| Z2 → Z3 | L4 (policy decision point) |
| Z3 → Z4 | L6 (orchestrator/BFF issues a signed internal envelope) |
| Within Z4 | L7 verifies envelope on every hop |

Concrete vendor mappings for each layer live in [`profiles/`](profiles/).
