---
name: architecture-review
description: Review a change for compliance with the security-first platform architecture — layer assignment, implementation neutrality, profile consistency, agent-as-client, envelope handling, tenant isolation, observability. Use when a PR touches architecture documents, profiles, or any component that maps to one of the eight control layers.
---

# Architecture review

Audit a change against the eight-layer control model and the security-first platform principles. The goal is to catch architectural drift early, before it solidifies in code.

## Inputs

- The PR or diff under review (assume `origin/main` as the base unless told otherwise).
- The repo's declared deployment profile (from `security-first-adoption.md` or the architecture-repo's `README.md`).
- Path to the repo (default: current working directory).

## Procedure

1. **Enumerate the diff.** Determine the touched files:

   ```bash
   git diff --name-only origin/main...HEAD
   ```

   Bucket each touched file:
   - `architecture/*.md` (depth 1) → architecture concept
   - `architecture/profiles/*.md` → profile mapping (vendor names allowed here)
   - `infra/profiles/<name>/**` → reference infrastructure
   - `standards/*.md`, `team-os/*.md` → neutral core
   - `templates/**` → consumer-facing template change
   - other → assess individually

2. **Run the automated validator** for vendor leakage and missing required files:

   ```bash
   bash scripts/validate-architecture.sh
   ```

   This enforces:
   - Required architecture files exist (depth-1 in `architecture/`).
   - No vendor NAME leaks in `architecture/*.md`.
   - No vendor-FILE-as-universally-required leaks in `team-os/`, `standards/`, or `architecture/overview.md`.

   Parse `[LEAK]` and `[MISSING]` lines. Each is a `BLOCK` until resolved.

3. **Layer assignment review.** For each new or changed component, identify which of the eight control layers it satisfies. Flag components without a layer. Use this checklist:

   ```
   L1 — Network reachability     ____
   L2 — Edge gateway / routing   ____
   L3 — Identity                 ____
   L4 — Authorization            ____
   L5 — Operational guardrails   ____
   L6 — Orchestrator / BFF       ____
   L7 — Service-level            ____
   L8 — Semantic / agent         ____
   ```

   A component with no entry is a `BLOCK` until classified.

4. **Profile consistency.** Confirm the change does not weaken a profile's contract from [`../../../architecture/control-layers.md`](../../../architecture/control-layers.md). If a profile cannot satisfy a layer's contract, a compensating control MUST be documented in the profile file (see [`../../../architecture/deployment-profiles.md`](../../../architecture/deployment-profiles.md) §"Compensating controls").

5. **Agent-as-client check.** If the change touches agent runtime behavior, confirm it follows [`../../../architecture/agent-as-client-model.md`](../../../architecture/agent-as-client-model.md). Coordinate with `security-control-review` if any code path is affected.

6. **Internal envelope check.** If the change touches L6→L7 internal calls, confirm envelope claims, issuance, and verification are intact per [`../../../architecture/internal-identity-envelope.md`](../../../architecture/internal-identity-envelope.md).

7. **Tenant isolation check.** If the change touches data access, confirm at least two of (identity, authorization, data partitioning) enforce tenancy per [`../../../architecture/multi-tenancy.md`](../../../architecture/multi-tenancy.md).

8. **Observability check.** Confirm every new code path emits the required signals from [`../../../architecture/observability.md`](../../../architecture/observability.md).

## Output

Return a short report with one paragraph per area above, ending in `PASS` / `WARN` / `BLOCK` per area and an overall recommendation. Include the raw `validate-architecture.sh` output. Each `BLOCK` must name the specific file or component and the architectural rule it violates.

Example shape:

```
File bucket count: 5 architecture, 2 standards, 1 infra, 1 template

validate-architecture.sh: PASS

Area-by-area:
  Layer assignment        PASS
  Profile consistency     WARN — new component in profiles/aws-managed.md weakens L5; compensating control documented
  Agent-as-client         n/a
  Internal envelope       PASS
  Tenant isolation        n/a
  Observability           BLOCK — new L7 service does not emit audit signal

Overall: BLOCK on observability
```

## Guardrails

- Do not review for code style, pure refactors, or CI configuration — use the appropriate skill (`github-enterprise-ci-review` for CI, none required for style).
- A `BLOCK` on any area must be resolved before merge; do not soften findings to keep a PR moving.
- For Tier 3 changes, reference this review's outcome in the OpenSpec proposal — do not let the review live only in the PR thread.

## See also

- [`../../../scripts/validate-architecture.sh`](../../../scripts/validate-architecture.sh)
- [`../../../architecture/control-layers.md`](../../../architecture/control-layers.md)
- [`../../../architecture/principles.md`](../../../architecture/principles.md)
- [`../../../standards/security-first-architecture-standard.md`](../../../standards/security-first-architecture-standard.md)
- [`../security-control-review/SKILL.md`](../security-control-review/SKILL.md)
