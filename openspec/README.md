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

- [`proposals/2026-05-17-coverage-and-polish/`](proposals/2026-05-17-coverage-and-polish/) — Tier 2, in_review (PR-4)

## Archived proposals

- [`archive/2026-05-16-enforcement-and-skill-rigor/`](archive/2026-05-16-enforcement-and-skill-rigor/) — Tier 2, accepted, architecture-complete (merged in PR-3)
