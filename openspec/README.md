# openspec/

This directory holds **OpenSpec** proposals for governed changes in this repository. See [`../team-os/openspec-policy.md`](../team-os/openspec-policy.md) for the policy (when OpenSpec is required, the three tiers, and the completion-state model) and [`../standards/openspec-standard.md`](../standards/openspec-standard.md) for the file layout.

## Layout

```
openspec/
  README.md                   # this file
  proposals/
    YYYY-MM-DD-short-title/
      proposal.md             # tier, problem, proposed change, alternatives, impact, affected consumers
      change.md               # concrete file diffs and contract before/after
      tasks.md                # execution plan with completion_state
  archive/                    # completed proposals (architecture-complete + adoption-complete)
```

## Creating a new proposal

1. Pick a date and a short title. Create `proposals/YYYY-MM-DD-<short-title>/`.
2. Copy templates from `../templates/openspec/`:

   ```bash
   D="openspec/proposals/$(date -u +%Y-%m-%d)-<short-title>"
   mkdir -p "$D"
   cp templates/openspec/proposal-template.md "$D/proposal.md"
   cp templates/openspec/change-template.md   "$D/change.md"
   cp templates/openspec/tasks-template.md    "$D/tasks.md"
   ```

3. Fill in frontmatter (`tier:`, `completion_state:`, etc.) and prose.
4. For Tier 2/3 with consumer impact: open one dependency record per affected consumer in `../portfolio/dependencies/` and link it from the proposal.

## CI enforcement

The `openspec-triage` workflow runs on PRs that touch architecture, standards, templates, skills, CI, or `AGENTS.md`. It calls `scripts/openspec-triage.sh` to classify the diff and confirm a proposal directory is present for Tier 2/3 changes.

## Current proposals

- [`proposals/2026-05-28-reusable-workflow-event-name-hotfix/`](proposals/2026-05-28-reusable-workflow-event-name-hotfix/) — Tier 2 by script-classification, **Tier-1 hotfix by intent**, in_review: reverts the PR #14 round-4 `github.event_name == 'workflow_call'` guard (always-false in reusable workflows) back to the round-3 `inputs.architecture_ref != ''` discriminator in `docs-healthcheck.yml` and `repo-healthcheck.yml`. Unblocks `platform-edge`'s step-1 PR. Will drive a `v0.1.1` tag after merge.

## Archived proposals

- [`archive/2026-05-16-enforcement-and-skill-rigor/`](archive/2026-05-16-enforcement-and-skill-rigor/) — Tier 2, accepted, architecture-complete (merged in PR #3)
- [`archive/2026-05-17-coverage-and-polish/`](archive/2026-05-17-coverage-and-polish/) — Tier 2, accepted, architecture-complete (merged in PR #8)
- [`archive/2026-05-17-audience-tiered-navigation/`](archive/2026-05-17-audience-tiered-navigation/) — Tier 2 by intent (script said Tier 3 due to path-based over-classification, documented), accepted, architecture-complete (merged in PR #11)
- [`archive/2026-05-17-repo-healthcheck-alignment/`](archive/2026-05-17-repo-healthcheck-alignment/) — Tier 2, accepted, architecture-complete (merged in PR #13)
- [`archive/2026-05-17-template-completeness-and-workflow-portability/`](archive/2026-05-17-template-completeness-and-workflow-portability/) — Tier 2 by intent (script said Tier 3 due to `standards/repo-contract.md` path; additive doc section), accepted, architecture-complete (merged in PR #14)
