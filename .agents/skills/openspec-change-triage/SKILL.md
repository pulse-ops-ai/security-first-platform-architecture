---
name: openspec-change-triage
description: Decide whether a change needs OpenSpec, and validate that an existing proposal follows the structure. Use when a PR is opened that may require OpenSpec, or when an OpenSpec proposal directory needs structural validation.
---

# OpenSpec change triage

Classify a change against the policy in [`../../../team-os/openspec-policy.md`](../../../team-os/openspec-policy.md) and, if a proposal exists, verify it follows the OpenSpec standard.

## Inputs

- The PR or diff under review.
- The repo's current `openspec/` directory (if any).

## Procedure

1. **Triage.** Classify the change:
   - **Tier 1** (no OpenSpec): docs polish, examples, additive opt-in skills/templates.
   - **Tier 2** (OpenSpec required): new/changed standard, template, or cross-repo contract.
   - **Tier 3** (OpenSpec + ADR required): architecture-layer change, profile change, agent-as-client rule change.
2. If Tier 2 or 3 and no proposal exists → recommend opening one using [`../../../templates/openspec/`](../../../templates/openspec/), and `BLOCK`.
3. If a proposal exists, validate:
   - Directory name matches `YYYY-MM-DD-short-title/`.
   - `proposal.md`, `change.md`, `tasks.md` are present.
   - `proposal.md` has Problem, Proposed change, Alternatives, Impact, Reviewers.
   - Cross-references are present (related ADRs, dependency records, affected repos).
4. Record each finding.

## Output

Return:

```
Tier:        2
Proposal:    openspec/proposals/2026-05-20-envelope-claims/
Findings:
  [OK]      proposal.md has required sections
  [MISSING] tasks.md
  [OK]      change.md cross-references envelope spec
```

Plus an overall verdict: `PASS`, `BLOCK`, or (for Tier 1) `NO OPENSPEC REQUIRED`.

## Guardrails

- Do not review proposal *content* — only structure. Architecture content review is `architecture-review`.
- Do not advise opening OpenSpec for Tier 1 work; that creates process drag.
- Tier 2/3 without a proposal is always a `BLOCK`. Do not soft-pass with "happy to add later."

## See also

- [`../../../team-os/openspec-policy.md`](../../../team-os/openspec-policy.md)
- [`../../../standards/openspec-standard.md`](../../../standards/openspec-standard.md)
- [`../../../templates/openspec/`](../../../templates/openspec/)
