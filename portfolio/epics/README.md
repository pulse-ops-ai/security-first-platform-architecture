# Epics

A **portfolio epic** is a multi-repo initiative tracked at the workspace level. It is not a Jira-style task list; it is a lightweight coordination doc.

## When to open an epic

- Work spans two or more repos and has a shared outcome.
- Sequencing matters: one repo must land before another can begin.
- The work is large enough that it would otherwise drift without a coordination point.

If the work fits inside one repo, it does not need a portfolio epic — open a normal issue or OpenSpec proposal there.

## Structure of an epic file

Create `portfolio/epics/YYYY-MM-DD-short-title.md` with at minimum:

```markdown
# Epic: <Title>

- **Opened:** YYYY-MM-DD
- **Owner:** <name / team>
- **Status:** proposed | in_progress | paused | done
- **Repos:** list of consuming repos

## Outcome
What does success look like?

## Architectural rationale
Why is this epic worth coordinating at the workspace level?

## Sequencing
Ordered list of milestones, with the repo responsible for each.

## Cross-references
- Related OpenSpec proposals
- Related ADRs
- Related dependency records (see ../dependencies/)
```

## Current epics

_None yet._
