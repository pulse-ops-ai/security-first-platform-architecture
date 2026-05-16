---
name: cross-repo-impact-review
description: Identify which consuming repos a change affects, and confirm dependency records exist. Use when a PR touches AGENTS.md, a standard, a template, an architecture document, OpenSpec/governance docs, or when opening a portfolio epic.
---

# Cross-repo impact review

For changes in the architecture repo, map which solution repos must respond, and confirm a dependency record exists for each affected consumer before merge.

## Inputs

- The PR or diff under review.
- The list of consuming repos (from [`../../../team-os/workspace-model.md`](../../../team-os/workspace-model.md) plus any sibling repos cloned under `~/work/security-first-platform/`).

## Procedure

1. **Classify the change.** Which artifacts are touched? (architecture, standards, templates, OpenSpec policy, profile mapping, envelope schema)
2. **Map artifacts → consumers.** For each touched artifact, list which consuming repos depend on it.
3. **Check for dependency records.** For each affected consumer, confirm a record exists in [`../../../portfolio/dependencies/`](../../../portfolio/dependencies/).
4. **Check sibling repos (if cloned).** Look for direct references to the touched artifacts in sibling repos under `../`.
5. Record findings.

## Output

Return:

```
Touched artifacts:
  - architecture/internal-identity-envelope.md
  - standards/security-first-architecture-standard.md

Affected consumers:
  - trupryce        (envelope verification in BFF)
  - findevil        (envelope verification in service mesh)
  - levelup-platform (not affected; no L6→L7 internal calls yet)

Dependency records:
  - [MISSING] No record for trupryce
  - [OK]      portfolio/dependencies/2026-05-10-findevil-depends-on-architecture-envelope.md

Recommendation: open a dependency record for trupryce before merging.
```

## Guardrails

- Do not silently merge a Tier 2+ change without dependency records for affected consumers — that hides coordination cost.
- Do not assume "no record means no impact"; verify by scanning sibling repos when they are cloned locally.
- Do not edit other repos as part of this skill — only report.

## See also

- [`../../../team-os/cross-repo-governance.md`](../../../team-os/cross-repo-governance.md)
- [`../../../portfolio/`](../../../portfolio/)
- [`../../../templates/dependency-record/dependency-template.md`](../../../templates/dependency-record/dependency-template.md)
