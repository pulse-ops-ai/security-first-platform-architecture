# OpenSpec Policy

**OpenSpec** is the governed-change protocol. It is heavier than a normal PR and exists to force **design alignment** before code lands.

This document defines the three tiers, when each applies, and what each requires. The mirror in [`../standards/openspec-standard.md`](../standards/openspec-standard.md) defines the *structure* of an OpenSpec proposal on disk; this document defines *policy* — when a proposal is required at all.

## Tiers

### Tier 1 — local docs or non-contractual cleanup

A change is Tier 1 if **all** of the following hold:

- It does not modify any repo contract, standard, template, skill body, CI gate, or security boundary.
- It does not change `AGENTS.md` or any adapter file's routing behavior.
- It does not change a cross-repo contract (envelope schema, API shape, observability schema, …).
- It is purely additive and opt-in, OR it is a wording/example/link fix.

Examples: typo fixes, doc clarifications, additive opt-in skills, new ADRs that record an existing decision, dependency bumps, formatting passes, CI script bug fixes that don't change behavior.

**Requirement: normal PR.** No OpenSpec needed.

### Tier 2 — repo contract / standard / template / skill / CI / OpenSpec / architecture behavior

A change is Tier 2 if **any** of the following hold:

- It modifies a standard (`standards/*.md`) or the repo contract.
- It modifies a template (`templates/*`) that consuming repos copy.
- It modifies a skill's procedure, output, or guardrails in a way that changes the skill's contract.
- It modifies a CI gate (`.github/workflows/*.yml`) in a way that changes what's required to merge.
- It modifies `team-os/openspec-policy.md`, `standards/openspec-standard.md`, or any OpenSpec template.
- It introduces a new control-layer responsibility, profile, or adapter that consumers may need to adopt.
- It modifies an architecture document (`architecture/*.md`) below the architecture-decision threshold (i.e., refines existing behavior without breaking the eight-layer model).
- It is a structural change in a consuming repo that affects how that repo integrates with the workspace.

**Requirement: OpenSpec proposal.** Tier 2 proposals:

- MUST list **affected consumers** in the Impact section by name.
- MUST link **one dependency record per affected consumer** in the Impact section by the time the proposal reaches `accepted` (see [`cross-repo-governance.md`](cross-repo-governance.md) §Dependency-record linkage).
- MUST declare a `completion_state:` (one of `architecture-complete` or `adoption-complete`) in `tasks.md`.
- MUST declare a `deprecation_window:` if they supersede an existing pattern (minimum: one consumer review-cadence cycle or 30 days).

### Tier 3 — cross-repo architecture or security-boundary change

A change is Tier 3 if **any** of the following hold:

- It changes the eight-layer control model itself (`architecture/control-layers.md`, `architecture/principles.md`).
- It changes the agent-as-client rule, the internal identity envelope schema, the trust-zone model, or the multi-tenancy contract.
- It deprecates or removes a deployment profile.
- It changes the universal floor of the repo contract.
- It changes the OpenSpec tiering rules themselves.

**Requirement: OpenSpec proposal + ADR.** Tier 3 proposals additionally:

- MUST produce an ADR in `docs/decisions/` capturing the trade-off.
- MUST target `completion_state: adoption-complete` (never `architecture-complete`).
- MUST coordinate with every active consumer's `security-first-adoption.md`; affected consumers must explicitly acknowledge before the proposal moves to `accepted`.

## Tier classification examples

| Change | Tier |
|---|---|
| Fix a broken link in `team-os/INDEX.md` | 1 |
| Add a new ADR for a decision already made | 1 |
| Add an opt-in skill under `.agents/skills/` that no consumer is required to use | 1 |
| Add a new field to the dependency-record schema | 2 |
| Tighten `validate-architecture.sh` to scan additional directories | 2 |
| Rename `architecture/profiles/aws-managed.md` and update all cross-refs | 2 |
| Add a new deployment profile (`azure-managed`) | 2 |
| Change `AGENTS.md` to require a new behavior from every agent | 2 (borderline → 3 if it breaks any consumer) |
| Change the internal identity envelope claim schema | 3 |
| Remove or supersede `architecture/profiles/self-hosted-vps.md` | 3 |
| Change the eight-layer model to seven or nine layers | 3 |

When in doubt between Tier 1 and Tier 2, the `openspec-change-triage` skill decides. When in doubt between Tier 2 and Tier 3, escalate to the platform team — Tier 3 has stricter coordination requirements and you don't want to discover the upgrade mid-review.

## What every OpenSpec proposal contains

Use [`../templates/openspec/proposal-template.md`](../templates/openspec/proposal-template.md). At minimum:

1. **Tier.** Stated explicitly. The `openspec-change-triage` skill validates it.
2. **Problem.** What is forcing this change?
3. **Proposal.** The change, stated plainly.
4. **Alternatives considered.** Why this and not the others.
5. **Impact.** Affected repos by name, affected standards / profiles / layers, affected adopters.
6. **Affected consumers + dependency records.** Tier 2/3 only. One row per consumer, linked to a dependency record.
7. **Migration plan + deprecation window.** How current consumers move; how long old and new coexist.
8. **Completion criteria.** Architecture-complete vs adoption-complete; what evidence proves done.
9. **Approval.** Reviewers, owners, target decision date.

The companion files:

- [`../templates/openspec/change-template.md`](../templates/openspec/change-template.md) — the concrete change spec (file diffs, contract before/after).
- [`../templates/openspec/tasks-template.md`](../templates/openspec/tasks-template.md) — the execution plan with `completion_state:` and per-consumer integration tasks.

## Where OpenSpec lives

- Architecture repo: `openspec/` (created when the first proposal lands).
- Consuming repos: `openspec/` per the repo contract — required once the consumer opens its first Tier 2/3 proposal.

## OpenSpec and CI

The `openspec-change-triage` skill ([`../.agents/skills/openspec-change-triage/SKILL.md`](../.agents/skills/openspec-change-triage/SKILL.md)) runs in CI and locally to:

- Classify the change as Tier 1/2/3.
- Confirm an OpenSpec proposal exists when Tier 2/3 is required.
- Confirm the proposal lists affected consumers and links the required dependency records.
- Confirm `completion_state:` is declared and `deprecation_window:` is set when a pattern is being superseded.
- Confirm linked ADRs exist for Tier 3.

## Anti-patterns

- **OpenSpec for everything.** Slows the team down for no gain.
- **OpenSpec after the fact.** OpenSpec is design alignment; running it after merge is paperwork.
- **OpenSpec without consumers in the loop.** Tier 2/3 changes require explicit consumer acknowledgement via dependency records.
- **Tier 2/3 with `completion_state: architecture-complete` on a contract swap.** A contract swap is by definition incomplete until consumers integrate. Calling it `architecture-complete` is a bug, not a shortcut.
- **Skipping the deprecation window** because "no consumer uses the old pattern yet." If you're sure, document it; don't silently elide the field.
