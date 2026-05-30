---
tier: 2
status: in_review
completion_state: architecture-complete
opened: 2026-05-29
target_decision_date: 2026-05-30
authors:
  - "@mike"
---

# OpenSpec Proposal: v0.3.0 housekeeping — archive proposals, cut v0.2.1 + v0.3.0 tags

## Problem

Five accepted proposals merged but were never archived, and two release tags the work produced were never cut:

- **PR #24** (v0.2.0 housekeeping), **PR #26** (v0.2.1 clarifications), **PR #27** (Phase C.2 templates), **PR #28** (Phase D `validate-diagrams.sh`), **PR #29** (Phase E consumer scaffold) all merged with their proposals still sitting in `openspec/proposals/` — the workspace's "PR-N+1 archives PR-N" convention means a follow-up PR moves them to `openspec/archive/`.
- **`v0.2.1`** (the standard clarifications, content on `main` at the #26 merge) and **`v0.3.0`** (the diagramming kit completion — C.2 + D + E) are untagged. `v0.2.1`'s own proposal said it ships "post-merge, or folds into the v0.3.0 housekeeping"; this is that fold.

Leaving them is low-harm but accumulates: `proposals/` stops reflecting "what's in flight," and consumers have no `v0.2.1` / `v0.3.0` ref to pin.

## Proposed change

Pure bookkeeping — **no functional changes**:

1. `git mv` the five proposal directories from `openspec/proposals/` to `openspec/archive/`; flip each `status: in_review → accepted` and add `accepted_date`, `archived_date: 2026-05-29`, and `merged_pr`.
2. Update `openspec/README.md`: `Current proposals` now lists only this housekeeping proposal; the five move to `Archived proposals` with their merge-PR numbers and tag annotations.
3. **Post-merge tags** (documented in `tasks.md` §Post-merge, not in this PR's diff):
   - `v0.2.1` at the #26 merge commit (`f3333ee`) — the v0.2.1 content state.
   - `v0.3.0` at this housekeeping PR's merge commit — the clean release state with all C.2/D/E proposals archived (mirrors the `v0.2.0` precedent, which was tagged at the v0.2.0-housekeeping merge, not the last content PR).

## Alternatives considered

- **Tag `v0.3.0` at the Phase E merge (#29) instead of this PR's merge.** Slightly more "the content is the release." Rejected to match the `v0.2.0` precedent (tagged at its housekeeping merge) so every release tag points at a tree where its proposals are already archived.
- **Cut `v0.2.1` as a standalone tag earlier, separate from this PR.** Valid (its content merged at #26). Folded here instead because the v0.2.1 proposal explicitly offered that option and it keeps both tags in one release-notes story.
- **Skip the proposal; just open a chore PR.** Rejected: the v0.2.0 housekeeping (PR #24) set the precedent that housekeeping PRs carry a proposal, and `openspec-triage` may classify the `openspec/` churn as Tier 2.

## Impact

- **Repos affected:** the architecture repo only. Tags become available for consumers to pin.
- **Standards / skills / templates / CI:** none — only `openspec/` file moves + `README.md`.
- **Cross-repo contracts:** none.
- **Security-boundary impact:** none.

## Affected consumers (Tier 2/3 only)

_None._ Bookkeeping; consumers may pin `v0.2.1` / `v0.3.0` at their convenience after the tags exist. No dependency record required.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`. **`deprecation_window:`** `n/a`.
- Steps: merge this PR → cut `v0.2.1` (at `f3333ee`) and `v0.3.0` (at this PR's merge) → push tags → draft the GitHub releases (notes in `tasks.md`).

## Completion criteria

`completion_state: architecture-complete`

- `openspec/proposals/` contains only this proposal; the five are under `openspec/archive/` with `status: accepted` + dates + `merged_pr`.
- `openspec/README.md` reflects the move.
- `pre-commit run --all-files`: 20/20 PASS. `validate-doc-indexes` PASS (the archived proposals are still indexed from `openspec/README.md`).
- `openspec-triage.sh`: Tier 2 with proposal present (or Tier 1 — either is fine for a bookkeeping move).
- `v0.2.1` and `v0.3.0` tags cut post-merge.

## Approval

- **Required reviewers:** platform team. **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md), [`tasks.md`](tasks.md).
- Archives: PR #24, #26, #27, #28, #29 proposals.
- This proposal itself is archived by the next housekeeping PR (per the convention).
- No ADRs, no dependency records.
