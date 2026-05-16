---
name: openspec-change-triage
description: Decide whether a change needs OpenSpec, and validate that an existing proposal follows the structure. Use when a PR is opened that may require OpenSpec, or when an OpenSpec proposal directory needs structural validation.
---

# OpenSpec change triage

Classify a change against [`../../../team-os/openspec-policy.md`](../../../team-os/openspec-policy.md) and, if a proposal exists, verify it follows the OpenSpec standard.

## Inputs

- The PR or diff under review.
- Base ref (default: `origin/main`).

## Procedure

1. **Run the automated triage script.**

   ```bash
   bash scripts/openspec-triage.sh origin/main
   ```

   The script:
   - Diffs against the base ref to list changed files.
   - Classifies each file as Tier 1, Tier 2, or Tier 3 per [`../../../team-os/openspec-policy.md`](../../../team-os/openspec-policy.md).
   - Takes the highest tier as the PR's tier.
   - If Tier 1 → exits `PASS` immediately.
   - If Tier 2/3 → requires a proposal directory under `openspec/proposals/YYYY-MM-DD-<short-title>/` touched by this PR, containing `proposal.md`, `change.md`, `tasks.md`.
   - Validates frontmatter: `tier:` and `completion_state:` present in `proposal.md`; `completion_state:` matches in `tasks.md`.
   - BLOCKS if Tier 3 targets `architecture-complete`.

2. **If the script BLOCKS, fix the diagnosed issue.** The script's output names the missing piece. Use the templates to scaffold:

   ```bash
   mkdir -p openspec/proposals/$(date -u +%Y-%m-%d)-<short-title>
   cp templates/openspec/proposal-template.md openspec/proposals/.../proposal.md
   cp templates/openspec/change-template.md   openspec/proposals/.../change.md
   cp templates/openspec/tasks-template.md    openspec/proposals/.../tasks.md
   ```

3. **For Tier 2/3 with consumer impact**, separately confirm dependency-record coverage by running the `cross-repo-impact-review` skill. The OpenSpec triage script does NOT check dependency-record coverage — that's the impact-review skill's job.

## Output

Return the script's output verbatim plus a one-line verdict:

```
Tier:        2
Proposal:    openspec/proposals/2026-05-20-envelope-claims/
Findings:
  [OK]      proposal.md frontmatter has tier and completion_state
  [MISSING] tasks.md
  [OK]      Tier matches proposal scope
Recommendation: add tasks.md before merge.
```

Or for Tier 1:

```
Tier:        1
Recommendation: no OpenSpec required.
```

## Guardrails

- Do not review proposal *content* — only structure and tier classification. Architecture content review is the `architecture-review` skill.
- Do not advise opening OpenSpec for Tier 1 work; that creates process drag.
- Tier 2/3 with no proposal is always a `BLOCK`. Do not soft-pass with "happy to add later."
- Tier 3 cannot target `architecture-complete`; that combination is always a `BLOCK`.
- This skill does NOT check dependency-record coverage. Run `cross-repo-impact-review` for that.

## See also

- [`../../../scripts/openspec-triage.sh`](../../../scripts/openspec-triage.sh)
- [`../../../team-os/openspec-policy.md`](../../../team-os/openspec-policy.md)
- [`../../../standards/openspec-standard.md`](../../../standards/openspec-standard.md)
- [`../../../templates/openspec/`](../../../templates/openspec/)
- [`../cross-repo-impact-review/SKILL.md`](../cross-repo-impact-review/SKILL.md)
