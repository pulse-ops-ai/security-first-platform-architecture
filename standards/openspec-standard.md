# OpenSpec Standard

How OpenSpec is **structured on disk** in each repo. The **policy** for when OpenSpec is required and the **tier definitions** live in [`../team-os/openspec-policy.md`](../team-os/openspec-policy.md). This document covers the file layout, naming, lifecycle, and required content.

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
    YYYY-MM-DD-short-title/     # completed proposals (architecture-complete + adoption-complete)
```

Use [`../templates/openspec/`](../templates/openspec/) to create new proposals.

## Naming

- Proposal directories are `YYYY-MM-DD-short-title/` where the date is the proposal's open date.
- `proposal.md` is the high-level proposal (tier, problem, alternatives, impact, affected consumers, completion criteria).
- `change.md` is the concrete change spec (file diffs, contract before/after, migration steps).
- `tasks.md` is the execution plan with per-consumer integration tasks and `completion_state`.

Splitting these three files keeps reviews focused: reviewers can engage with the *problem* (proposal) before getting into the *mechanism* (change) or the *plan* (tasks).

## Lifecycle

A proposal moves through these states:

1. **Draft.** PR opened with the proposal directory under `openspec/proposals/`. `tier:` declared in frontmatter.
2. **Review.** Reviewers from the platform team and each affected consuming repo's lead. Dependency records opened for each affected consumer.
3. **Accepted.** Decision recorded in `proposal.md`. Tasks may begin. For Tier 3, the ADR is written.
4. **Architecture-complete.** Architecture-side PRs merged at the target ref. Dependency records move to `in_progress`.
5. **Adoption-complete.** All affected consumers have integrated and updated their `security-first-adoption.md`. Deprecation window (if any) has elapsed. Dependency records move to `resolved`.
6. **Archived.** Directory moved to `openspec/archive/` once the proposal's target `completion_state` is reached.

A proposal targeting `completion_state: architecture-complete` archives after step 4. A proposal targeting `completion_state: adoption-complete` archives after step 5. The choice is declared explicitly in `tasks.md`.

## Required content (minimum)

`proposal.md` must include:

- Frontmatter with `tier:` (1, 2, or 3) and `completion_state:` (`architecture-complete` or `adoption-complete`)
- Title and date
- Problem statement
- Proposed change (one paragraph)
- Alternatives considered
- Impact (repos, layers, standards, profiles, security boundaries)
- **Affected consumers** — one row per consumer, with a link to the matching dependency record (Tier 2/3 only)
- Migration plan + deprecation window
- Reviewers and target decision date

`change.md` must include:

- Concrete file diffs or before/after structure
- Contract changes (envelope claims, API shapes, observability schema, etc.)
- Migration steps for consuming repos
- Rollback plan or explicit "rollback not feasible" with compensating safeguards

`tasks.md` must include:

- `completion_state:` declared explicitly
- Ordered architecture-side task list with owners and rough estimates
- **Per-consumer integration tasks** (Tier 2/3) — one section per affected consumer
- Cross-repo task references where applicable
- Definition-of-done checklist matching the declared `completion_state`

## Anti-patterns

- **One huge `proposal.md` covering everything.** Split into proposal / change / tasks.
- **Skipping the alternatives section.** Reviewers need to know what was considered and why this won.
- **Tasks list with no owners.** A task without an owner is a wish.
- **Archive that never grows.** If proposals stay open forever, the team isn't actually using OpenSpec to ship.
- **`completion_state: architecture-complete` on a contract swap.** A contract swap is incomplete until consumers integrate.
- **Bulk affected-consumers entries** ("all consumers track this"). Each consumer needs its own dependency record.

## Verification

The `openspec-change-triage` skill ([`../.agents/skills/openspec-change-triage/SKILL.md`](../.agents/skills/openspec-change-triage/SKILL.md)) confirms:

- The proposal's `tier:` matches the actual scope of the change.
- Tier 2/3 proposals list affected consumers with dependency-record links.
- `completion_state:` is declared and consistent with the proposal's scope.
- `deprecation_window:` is set when a pattern is superseded.
- Required files are present.
- Tier 3 has an associated ADR.
