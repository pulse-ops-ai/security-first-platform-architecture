# OpenSpec Standard

How OpenSpec is structured *inside* each repo. The **policy** for when OpenSpec is required lives in [`../team-os/openspec-policy.md`](../team-os/openspec-policy.md). This file describes the **structure** of the `openspec/` directory.

## Directory layout

```
openspec/
  README.md                     # what OpenSpec is in this repo
  proposals/
    YYYY-MM-DD-short-title/
      proposal.md
      change.md
      tasks.md
      decisions/                # optional — supporting decisions
      reviews/                  # optional — review notes
  archive/
    YYYY-MM-DD-short-title/     # completed proposals
```

Use [`../templates/openspec/`](../templates/openspec/) to create new proposals.

## Naming

- Proposal directories are `YYYY-MM-DD-short-title/` where the date is the proposal's open date.
- `proposal.md` is the high-level proposal (problem, alternatives, impact).
- `change.md` is the concrete change spec (what files change, what contracts move).
- `tasks.md` is the execution plan.

Splitting these three files keeps reviews focused: reviewers can engage with the *problem* (proposal) before getting into the *mechanism* (change) or the *plan* (tasks).

## Lifecycle

1. **Draft.** PR opened with the proposal directory under `openspec/proposals/`.
2. **Review.** Reviewers from the platform team and affected consuming repos.
3. **Accepted.** Decision recorded in `proposal.md`; tasks may begin.
4. **Executed.** Tasks completed; cross-references back to merged PRs added.
5. **Archived.** Directory moved to `openspec/archive/` once the change is fully landed.

## Required content (minimum)

`proposal.md`:

- Title and date
- Problem statement
- Proposed change (one paragraph)
- Alternatives considered
- Impact (repos, layers, standards, profiles)
- Reviewers and target decision date

`change.md`:

- Concrete file diffs or before/after structure
- Contract changes (envelope claims, API shapes, etc.)
- Migration steps for consuming repos

`tasks.md`:

- Ordered task list with owners and rough estimates
- Cross-repo task references where applicable

## Anti-patterns

- **One huge `proposal.md` covering everything.** Split into proposal / change / tasks.
- **Skipping the alternatives section.** Reviewers need to know what was considered and why this won.
- **Tasks list with no owners.** A task without an owner is a wish.
- **Archive that never grows.** If proposals stay open forever, the team isn't actually using OpenSpec to ship.

## Verification

The `openspec-change-triage` skill ([`../.agents/skills/openspec-change-triage/SKILL.md`](../.agents/skills/openspec-change-triage/SKILL.md)) confirms structure, links, and required fields.
