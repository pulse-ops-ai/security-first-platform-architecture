# OpenSpec Policy

**OpenSpec** is the governed-change protocol. It is a heavier process than a normal PR, and is required only when a change needs **design alignment** before code lands.

## When OpenSpec is required

A change requires an OpenSpec proposal if **any** of the following are true:

1. It modifies an architecture document (`architecture/*.md`, including `profiles/*.md`).
2. It modifies a standard (`standards/*.md`).
3. It modifies `AGENTS.md` or the universal contract surface.
4. It changes a template that consuming repos use (`templates/*`).
5. It changes a cross-repo contract (API shape, data contract, identity envelope schema, observability schema).
6. It introduces a new control layer responsibility, profile, or skill that other repos must adopt.
7. It is a structural change in a consuming repo that affects how it integrates with the rest of the workspace.

## When OpenSpec is NOT required

A normal PR is sufficient for:

- Wording, examples, link fixes, typo fixes.
- New ADRs (the ADR itself is the artifact).
- New skills or templates that are **additive and opt-in** and do not change existing contracts.
- Routine maintenance (dependency bumps, CI fixes, formatting).

When in doubt, ask. It is cheaper to skip OpenSpec on a no-impact change than to retrofit one onto a high-impact change.

## What an OpenSpec proposal contains

Use [`../templates/openspec/proposal-template.md`](../templates/openspec/proposal-template.md). At minimum:

1. **Problem.** What is forcing this change?
2. **Proposal.** The change, stated plainly.
3. **Alternatives considered.** Why this and not the others.
4. **Impact.** Which repos, which standards, which profiles.
5. **Migration plan.** How current consumers move to the new state.
6. **Approval.** Reviewers, owners, and timing.

See also:

- [`../templates/openspec/change-template.md`](../templates/openspec/change-template.md) — the actual change spec
- [`../templates/openspec/tasks-template.md`](../templates/openspec/tasks-template.md) — the execution plan

## Where OpenSpec lives

- Architecture repo: `openspec/` (will be created when the first proposal lands).
- Consuming repos: `openspec/` per the repo contract.

## OpenSpec and CI

The `openspec-change-triage` skill ([`../.agents/skills/openspec-change-triage/SKILL.md`](../.agents/skills/openspec-change-triage/SKILL.md)) can be invoked in CI or locally to:

- Confirm an OpenSpec proposal exists for changes that require one.
- Confirm the proposal follows the template.
- Confirm linked dependency records and ADRs exist.

## Anti-patterns

- **OpenSpec for everything.** Slows the team down for no gain.
- **OpenSpec after the fact.** OpenSpec is design alignment; running it after the code is merged is paperwork.
- **OpenSpec without consumers in the loop.** Tier 2+ changes require explicit acknowledgement from affected solution repos.
