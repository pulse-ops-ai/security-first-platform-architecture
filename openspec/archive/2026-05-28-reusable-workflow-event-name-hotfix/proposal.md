---
tier: 2
status: accepted
completion_state: architecture-complete
opened: 2026-05-28
target_decision_date: 2026-05-28
accepted_date: 2026-05-28
archived_date: 2026-05-28
merged_pr: 20
authors:
  - "@mike"
---

# OpenSpec Proposal: Reusable-workflow event-name guard hotfix

## Problem

`platform-edge` opened its step-1 pass-through PR pinning `architecture_ref: v0.1.0` and invoked the reusable `repo-healthcheck.yml` and `docs-healthcheck.yml` workflows via thin callers. **Both workflows failed** with:

```
Run if [[ "pull_request" == 'workflow_call' ]]; then
ERROR: self-mode expects scripts/repo-healthcheck.sh in the caller's checkout.
Error: Process completed with exit code 1.
```

Root cause is a bug I introduced in **PR #14 round-4** (commit `b160dec`): I gated the consumer-mode dual-checkout step on `if: github.event_name == 'workflow_call'` as a defense-in-depth response to a Copilot finding. That gate is **always false in a reusable workflow** because GitHub Actions' `github` context in a reusable workflow reflects the **caller's** event (`pull_request`, `push`, etc.), not the literal string `workflow_call`. This is a documented GitHub Actions behaviour:

> "When you use a reusable workflow, the `github` context is always evaluated in the context of the caller workflow."

The consequence: in every consumer-mode invocation, the `github.event_name == 'workflow_call'` check evaluates to `false`, the `.arch-tools/` sparse-checkout step is skipped, and the script-selection step falls into the **self-mode** branch — which then errors out because the consumer's repo has no `scripts/repo-healthcheck.sh`.

The architecture repo's own CI never caught this because self-mode CI on the architecture repo IS triggered by `pull_request` / `push`, and `inputs.architecture_ref` IS empty there — so the buggy gate happens to evaluate the same way as the correct gate in self-mode. The bug is invisible until a real consumer calls the workflow. `platform-edge` is the first real consumer; it surfaced the bug on its first attempt.

## Proposed change

One-line revert per workflow, in two workflows. Revert to the PR #14 **round-3** design (commit `7dfeaa4`), which gated on `inputs.architecture_ref != ''` and was correct.

### `.github/workflows/docs-healthcheck.yml`

- Step *"Checkout architecture repo for scripts (consumer call only)"*: change `if: github.event_name == 'workflow_call'` → `if: inputs.architecture_ref != ''`.
- Step *"Determine script path"*: change the bash discriminator from `if [[ "${{ github.event_name }}" == 'workflow_call' ]]; then` → `if [[ -n "${{ inputs.architecture_ref }}" ]]; then`.
- Inline comments updated to document **why** the `inputs` discriminator is correct and `github.event_name` is wrong, so a future contributor (or future me) does not re-introduce the bug.

### `.github/workflows/repo-healthcheck.yml`

- Same two changes; same comment updates.

### What does NOT change

- `architecture_ref: required: true` on the `workflow_call` input — still correct. The required flag enforces presence at the GitHub Actions API surface; a consumer caller cannot accidentally omit it. Combined with the `inputs.architecture_ref != ''` discriminator, this means consumer-mode is guaranteed-non-empty and self-mode is guaranteed-empty.
- The mode-strict no-fallback design (consumer mode MUST use `.arch-tools/scripts/...`; self mode MUST use the caller's own `scripts/...`; no cross-mode fallback) — still correct. PR #14 round-4 fixed a real security concern (a consumer could otherwise vendor a tweaked script and pass) and that fix stays.
- `pre-commit.yml` is not affected — it has no dual-checkout step and is not buggy.

## Alternatives considered

- **Use `inputs.architecture_ref != ''` only and drop `required: true`.** Simpler frontmatter. Rejected because `required: true` is the correct enforcement at the workflow_call API surface — it makes the contract explicit and prevents callers from accidentally passing the empty string and silently dropping into self-mode.
- **Add a separate `mode:` input.** A consumer would pass `mode: consumer` and the gate would check the input. Rejected because (a) it adds redundant ceremony — `architecture_ref` already disambiguates; (b) consumer-mode is already enforced by `required: true` plus the `inputs.architecture_ref != ''` check; (c) it would be a breaking change to the consumer template.
- **Add a workflow_call-only canary file in `.arch-tools/`.** Check for existence of that file as the discriminator. Rejected as roundabout when the `inputs` context discriminator works directly.
- **Don't fix; tell consumers to copy and adapt the workflow.** Defeats the point of reusable workflows. Rejected.

## Impact

- **Repos affected:** the architecture repo only in this PR. After tagging `v0.1.1`, `platform-edge` and any future consumer will repin from `v0.1.0` to `v0.1.1`.
- **Layers / profiles affected:** none. This is CI plumbing.
- **Standards affected:** none. No change to `ci-cd-standard.md` or `repo-contract.md`.
- **Templates affected:** none. The consumer template's thin-caller workflows are unchanged; only the reusable workflows they invoke are fixed.
- **Cross-repo contracts:** none — the input names and shapes are unchanged. `architecture_ref: required: true` continues; the discriminator change is internal to the reusable workflow.
- **Security-boundary impact:** none. The mode-strict no-fallback design from PR #14 round-4 stays. The hotfix only fixes which branch of that design actually runs.

## Affected consumers (Tier 2/3 only)

| Consumer repo | Affected artifact | Dependency record | Owner |
|---|---|---|---|
| platform-edge | `security-first-adoption.md` `architecture_ref:` (v0.1.0 → v0.1.1 bump after merge), `.github/workflows/{repo-healthcheck,docs-healthcheck}.yml` `@ref` lines | not required — handled inline (see Migration plan) | `@mikegtech` |
| trupryce | none — its adoption record points at v0.1.0 and is `resolved`; this fix becomes available at the next routine `architecture_ref` bump (no current need to repin) | not required | `@mikegtech` / `@trupryce-platform` |

Per the §Dependency-record linkage rule in `team-os/cross-repo-governance.md`, this change has "downstream impact" for `platform-edge` (its CI is currently broken until it repins). A dedicated dependency record is **not** opened because the existing `DEP-2026-05-24-001` already names `platform-edge → architecture` at `v0.1.0`; we will simply bump that record's `upstream_ref:` to `v0.1.1` in a tiny housekeeping PR after `v0.1.1` is tagged. Opening a second record for the same direction would violate the "one record per direction per coordinated change" intent.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `upstream-first`.
- **`deprecation_window:`** `n/a` — the hotfix is a bug correction, not a behavior change for consumers who haven't yet successfully invoked the workflow.
- **Migration steps:**
  1. Merge this PR.
  2. Tag `v0.1.1` on the architecture repo `main`. Release notes: *"Hotfix: reusable-workflow event-name guard. PR #14 round-4 introduced an `if: github.event_name == 'workflow_call'` gate that is always-false in reusable workflows (the `github` context reflects the caller's event). Reverted to the round-3 `inputs.architecture_ref != ''` discriminator, which is correct."*
  3. Tiny housekeeping PR in the architecture repo bumps `DEP-2026-05-24-001`'s `upstream_ref: v0.1.0 → v0.1.1` (one line).
  4. `platform-edge` updates its step-1 PR: bump `architecture_ref: v0.1.0 → v0.1.1` in `security-first-adoption.md`; bump the three thin-caller `@ref` lines in `.github/workflows/{repo-healthcheck,docs-healthcheck,pre-commit}.yml`; push. CI should turn green.
  5. trupryce: no action required. Its adoption record stays at `v0.1.0`. When trupryce next has reason to bump, it will naturally inherit the fix.

## Tier classification note (script vs intent)

`scripts/openspec-triage.sh` will classify this PR as **Tier 2** because the diff touches `.github/workflows/*.yml`, which is in the script's Tier-2 path list. That matches the *path-based* classification, and we honour it by filing this proposal.

By **intent**, this is a Tier-1 hotfix — a one-line bug revert per workflow, no contract change, no shape change, no consumer-impact except *unblocking* consumers who currently cannot use the workflows at all. There is no architectural decision being made here; we are simply correcting a misapplication of a Copilot review suggestion from PR #14 round-4 to PR #14 round-3 (which was already correct).

We file the proposal because the script says Tier 2, and we honour the rule rather than argue with the classifier; but reviewers should treat this as a hotfix and not require the full ceremony (e.g., the target-decision-date is the same day as the open date because the change is mechanical and time-pressured by an actively-broken consumer).

## Completion criteria

`completion_state: architecture-complete`

- `.github/workflows/docs-healthcheck.yml` and `.github/workflows/repo-healthcheck.yml` both have the `inputs.architecture_ref != ''` discriminator in the dual-checkout step.
- Both workflows have the `[[ -n "${{ inputs.architecture_ref }}" ]]` discriminator in the script-selection step.
- Inline comments document **why** `github.event_name` is wrong in reusable workflows, to prevent re-introduction.
- Self-mode CI on the architecture repo's own PRs still passes (this PR is its own first test).
- All 19 pre-commit hooks pass.
- `openspec-triage.sh` classifies this PR as Tier 2 with proposal present.
- After merge: `v0.1.1` is tagged + released; `DEP-2026-05-24-001` `upstream_ref` is bumped; `platform-edge` repins and its CI turns green.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus, expedited (hotfix unblocking a consumer).

## Linked artifacts

- [`change.md`](change.md) — concrete file diffs.
- [`tasks.md`](tasks.md) — execution plan.
- No ADRs — visual decision is unchanged, no architectural trade-off, mechanical bug revert.
- Related: [`portfolio/dependencies/2026-05-24-platform-edge-depends-on-security-first-platform-architecture-onboarding.md`](../../../portfolio/dependencies/2026-05-24-platform-edge-depends-on-security-first-platform-architecture-onboarding.md) — the dependency record that will get its `upstream_ref` bumped after `v0.1.1` is tagged.
- PR #14 round-3 (commit `7dfeaa4`) — the original correct design this PR restores.
- PR #14 round-4 (commit `b160dec`) — the regression this PR fixes.
- PR #19 (open) — diagramming conventions + skills, independent of this hotfix; both can land in either order.
