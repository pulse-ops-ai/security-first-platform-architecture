---
name: security-control-review
description: Review a change for control-layer integrity, trust-zone crossings, agent-as-client compliance, and audit emission. Use when a PR touches authentication, authorization, request routing, envelope handling, audit, agent runtime behavior, or any path crossing trust zones.
---

# Security control review

For changes that touch the security stack, verify trust-zone crossings have the required evidence, agents remain clients (never insiders), and audit-class events emit to the audit sink rather than operational logs.

## Inputs

- The PR or diff under review.
- The repo's declared deployment profile.

## Procedure

1. **Trust-zone crossings.** For every code path in the change, list the trust zones it crosses (Z0–Z4 per [`../../../architecture/security-boundaries.md`](../../../architecture/security-boundaries.md)).
2. **Crossing evidence.** Confirm each crossing has the required evidence:
   - Z0→Z1: routing/WAF disposition
   - Z1→Z2: verified L3 token
   - Z2→Z3: L4 decision
   - Z3→Z4: signed internal envelope
   - Within Z4: envelope verification on every hop
3. **No network-as-identity.** Scan for code that trusts IP, hostname, VPC membership, or service-mesh-only identity as authentication. Flag.
4. **Agent paths.** If agents are involved, verify they pass through L1→L4 like any other client. Verify `principal_type=agent` and `actor` are handled per [`../../../architecture/agent-as-client-model.md`](../../../architecture/agent-as-client-model.md).
5. **Audit emission.** Confirm security-relevant events emit to the audit sink — not just operational logs.
6. **Fail-closed.** Confirm error paths fail closed (deny by default), not fail-open.
7. **Secrets handling.** No secrets in logs, no long-lived credentials in code.

## Output

Return a control-by-control report with `PASS` / `BLOCK` / `WARN` per area and rationale per finding. Each `BLOCK` must name the file or code path and the trust-zone rule it violates.

## Guardrails

- Any `BLOCK` must be resolved before merge — do not soften findings.
- Do not approve a fail-open error path. Fail-closed is the default; fail-open requires an explicit ADR.
- Do not treat service-mesh identity or VPC membership as authentication evidence, even if the code "happens to work."

## See also

- [`../../../architecture/security-boundaries.md`](../../../architecture/security-boundaries.md)
- [`../../../architecture/identity-and-authorization.md`](../../../architecture/identity-and-authorization.md)
- [`../../../architecture/internal-identity-envelope.md`](../../../architecture/internal-identity-envelope.md)
- [`../../../architecture/agent-as-client-model.md`](../../../architecture/agent-as-client-model.md)
