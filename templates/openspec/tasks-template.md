---
completion_state:            # architecture-complete | adoption-complete — MUST match proposal.md
---

# OpenSpec Tasks: <Title>

Execution plan for the change described in `proposal.md` and `change.md`.

## Architecture-side tasks

Tasks in the architecture repo (this repo).

| # | Task | Owner | Status | PR / link |
|---|------|-------|--------|-----------|
| 1 | <task description> | @handle | pending | |
| 2 | <task description> | @handle | pending | |

## Per-consumer integration tasks (Tier 2/3 with consumer impact)

One section per affected consumer named in `proposal.md`. A task list without an owner per consumer is incomplete.

### Consumer: `<repo-name>`

- Dependency record: [`<dep-id>`](../../portfolio/dependencies/<file>.md)
- Owner: @handle
- Target ref: `<sha-or-tag>` (matches `upstream_ref:` in the dependency record)

| # | Task | Status | PR / link |
|---|------|--------|-----------|
| 1 | Update `security-first-adoption.md`: bump `architecture_ref`, add to `pending_openspec_changes`, then drain | pending | |
| 2 | Integrate the new contract / template / standard | pending | |
| 3 | Run repo-healthcheck + cross-repo-impact-review skills | pending | |

### Consumer: `<repo-name-2>`

<!-- Repeat the consumer block per affected consumer. -->

## Dependencies between tasks

Describe ordering constraints — within and across repos. E.g., "Task 3 in `trupryce` cannot start until architecture-side Task 1 lands at the target ref."

## Cutover plan

If applicable: which task represents the cutover, what happens before it, and what is allowed/forbidden in the deprecation window around it. Reference `deprecation_window:` from `proposal.md`.

## Definition of done

Match the declared `completion_state:` in frontmatter.

### If `completion_state: architecture-complete`

- [ ] All architecture-side tasks resolved
- [ ] Healthcheck workflows green on the architecture repo
- [ ] ADR (if Tier 3) written and merged
- [ ] Architecture-side dependency records moved to `in_progress`
- [ ] Proposal status set to `accepted`

### If `completion_state: adoption-complete`

- [ ] All architecture-side AND per-consumer tasks resolved
- [ ] Healthcheck workflows green in every affected repo
- [ ] ADR (if Tier 3) written and merged
- [ ] Every affected consumer's `security-first-adoption.md` updated to the new state
- [ ] Every affected consumer's dependency record moved to `resolved`
- [ ] Deprecation window (if any) has fully elapsed
- [ ] Old artifact removed (if the change supersedes a pattern)
- [ ] Proposal moved to `openspec/archive/`
