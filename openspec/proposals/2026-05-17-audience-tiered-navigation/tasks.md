---
completion_state: architecture-complete
---

# OpenSpec Tasks: Audience-Tiered Navigation

Execution plan for [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Architecture-side tasks

| # | Task | Owner | Status | PR / link |
|---|------|-------|--------|-----------|
| 1 | Rewrite `README.md` as a thin landing page with the 6-row audience-tiered routing table | @mike | completed | this PR |
| 2 | Populate `docs/product/INDEX.md` with real content (promises, non-promises, owners, decisions, adoption path, current state, phase) | @mike | completed | this PR |
| 3 | Add `## Related decisions` section to `architecture/INDEX.md` linking ADR-0001, ADR-0002, ADR-0003 | @mike | completed | this PR |
| 4 | Add `> See ADR-0001 for the trade-off record.` callout to `architecture/control-layers.md` | @mike | completed | this PR |
| 5 | Add `> See ADR-0002 for the trade-off record.` callout to `architecture/agent-as-client-model.md` | @mike | completed | this PR |
| 6 | Add `> See ADR-0003 for the trade-off record.` callout to `architecture/internal-identity-envelope.md` | @mike | completed | this PR |
| 7 | Add `docs/decisions/INDEX.md` row to `AGENTS.md` "Where to find things" table | @mike | completed | this PR |
| 8 | Add `docs/decisions/INDEX.md` to `CLAUDE.md` "Read first" list | @mike | completed | this PR |
| 9 | Run all validators end-to-end; confirm PASS | @mike | completed | this PR |
| 10 | Run `pre-commit run --all-files`; confirm 18 pre-commit-stage hooks PASS | @mike | completed | this PR |
| 11 | Verify each of the six audience entry points in the new `README.md` table resolves to an existing file with real content | @mike | completed | this PR |

## Per-consumer integration tasks

None — `completion_state: architecture-complete`. No consumer must act. Future consumer `security-first-adoption.md` records will reference the new entry points; existing references to `README.md` continue to work because the file is restructured in place, not deleted or moved.

## Dependencies between tasks

- Task 3 depends on task 4–6 not being required first (they're independent additions).
- Task 9–11 depend on tasks 1–8 being complete.

## Cutover plan

No cutover. Each change is additive or in-place restructuring. The new README is a strict superset of the prior README's *routing* function and a strict subset of its *content* (the dropped content has moved to authoritative surfaces, not been deleted).

## Definition of done

`completion_state: architecture-complete`:

- [x] All architecture-side tasks resolved
- [x] All four pre-existing validators PASS (architecture, doc-indexes, skills, sync-agent-skills)
- [x] `check-infra-secrets.sh` and `check-network-as-identity.sh` PASS
- [x] `openspec-triage.sh` classifies this PR as Tier 3 (path-based heuristic) and PASSes with the proposal present; the proposal declares `tier: 2` to match the navigation-only intent. The script-vs-intent mismatch is documented in `proposal.md` § *Note on tier classification* and is a known limitation of the path-based classifier (same pattern accepted in PR-3 for `scripts/*`). No BLOCK fires; CI is unblocked.
- [x] `pre-commit run --all-files` — 18 hooks PASS
- [x] Manual: each entry point in the new README routes to a file with real content
- [x] No ADR required (Tier 2)
- [x] No dependency records (no consumer impact)
- [x] Proposal status moved from `in_review` → `accepted` on merge
- [x] After PR merge: proposal directory moves to `openspec/archive/` in the next PR (per the established pattern)
