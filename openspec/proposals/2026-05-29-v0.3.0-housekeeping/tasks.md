---
completion_state: architecture-complete
---

# OpenSpec Tasks: v0.3.0 housekeeping

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | `git mv` the five proposals to `openspec/archive/` | @mike | completed | this PR |
| 2 | Flip `status → accepted`; add `accepted_date` / `archived_date` / `merged_pr` to each | @mike | completed | this PR |
| 3 | `openspec/README.md`: move the five from Current → Archived; add this proposal to Current | @mike | completed | this PR |
| 4 | Write this proposal (`proposal.md`, `change.md`, `tasks.md`) | @mike | completed | this PR |
| 5 | Confirm `validate-doc-indexes` + `pre-commit run --all-files`: PASS | @mike | completed | this PR |
| 6 | Confirm `openspec-triage.sh origin/main` (Tier 1) | @mike | completed | this PR |
| 7 | Open PR | @mike | completed | this PR |

## Definition of done

### Pre-merge

- [x] `openspec/proposals/` contains only this proposal; the five are in `openspec/archive/` with `status: accepted` + dates + `merged_pr`.
- [x] `openspec/README.md` Current lists only this proposal; Archived lists all five with tag annotations.
- [x] `bash scripts/validate-doc-indexes.sh .`: PASS.
- [x] `bash scripts/repo-healthcheck.sh`: PASS.
- [x] `pre-commit run --all-files`: 20/20 PASS.
- [x] `openspec-triage.sh`: Tier 1 (bookkeeping); proposal present anyway.
- [x] No ADR; no dependency records; no functional changes.

## Per-consumer integration tasks

**n/a** — bookkeeping.

## Post-merge

The release tags are cut **after** this PR merges (not in the diff):

- [ ] **`v0.2.1`** — `git tag v0.2.1 f3333ee` (the PR #26 merge commit; the v0.2.1 content state) && `git push origin v0.2.1`.
- [ ] **`v0.3.0`** — `git tag v0.3.0 <this PR's merge commit>` && `git push origin v0.3.0`. Tagged at the housekeeping merge (proposals archived) per the `v0.2.0` precedent.
- [ ] Draft the two GitHub releases:
  - **`v0.2.1`** — "Diagramming-conventions clarifications. Future-ribbon labels use `#222222` bold (AA-safe); step-badge full-width-ribbon anchor + collision rule. Additive; existing diagrams grandfathered."
  - **`v0.3.0`** — "Diagramming kit completion. Archetype starter templates for all seven archetypes (C.2); `validate-diagrams.sh` paired-SVG + footer + contrast gate, pre-commit hook + consumer CI (D); consuming-repo `docs/diagrams/` scaffold (E). Additive; opt-in. Consumers bump `architecture_ref` to `v0.3.0` at their cadence."
- [ ] (Optional) bump `DEP-2026-05-24-001` further or leave at `v0.2.0` — `platform-edge` pins what it needs; low-stakes.

## Notes

- Tags are the only outward-facing, hard-to-reverse step; cut them only after merge, and prefer a follow-up patch tag over deleting a pushed tag if a fix is needed.
- This proposal is archived by the next housekeeping PR, per the "PR-N+1 archives PR-N" convention.
