---
name: architecture-review
description: Review a change for compliance with the security-first platform architecture — layer assignment, implementation neutrality, profile consistency, agent-as-client, envelope handling, tenant isolation, observability. Use when a PR touches architecture documents, profiles, or any component that maps to one of the eight control layers.
---

# Architecture review

Audit a change against the eight-layer control model and the security-first platform principles. The goal is to catch architectural drift early, before it solidifies in code.

## Inputs

- The PR or diff under review.
- The repo's declared deployment profile (from its `README.md` or `docs/`).

## Procedure

1. **Layer assignment.** For each new or changed component, identify which of the eight control layers it satisfies. Flag components without a layer.
2. **Implementation neutrality.** Scan `architecture/*.md` (excluding `profiles/`) for vendor names. Flag leaks.
3. **Profile consistency.** Confirm the change does not weaken a profile's contract. If it does, confirm a compensating control is documented.
4. **Agent-as-client.** If the change touches agent runtime behavior, confirm it follows [`../../../architecture/agent-as-client-model.md`](../../../architecture/agent-as-client-model.md).
5. **Internal envelope.** If the change touches L6→L7 internal calls, confirm envelope claims, issuance, and verification are intact.
6. **Tenant isolation.** If the change touches data access, confirm at least two of (identity, authorization, data partitioning) enforce tenancy.
7. **Observability.** Confirm every new code path emits the required signals from [`../../../architecture/observability.md`](../../../architecture/observability.md).

## Output

Return a short review with one paragraph per area above, ending in `PASS` or `BLOCK` per area and an overall recommendation. Each `BLOCK` must name the specific file or component and the architectural rule it violates.

## Guardrails

- Do not review for code style, pure refactors, or CI configuration — use the appropriate skill.
- A `BLOCK` on any area must be resolved before merge; do not soften findings to keep a PR moving.
- For Tier 3 changes, reference this review's outcome in the OpenSpec proposal — do not let the review live only in the PR thread.

## See also

- [`../../../architecture/control-layers.md`](../../../architecture/control-layers.md)
- [`../../../architecture/principles.md`](../../../architecture/principles.md)
- [`../../../standards/security-first-architecture-standard.md`](../../../standards/security-first-architecture-standard.md)
