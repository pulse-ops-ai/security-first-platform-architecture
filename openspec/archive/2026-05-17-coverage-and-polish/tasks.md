---
completion_state: architecture-complete
---

# OpenSpec Tasks: Coverage Closure and Polish

Execution plan for [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Architecture-side tasks

| # | Task | Owner | Status | PR / link |
|---|------|-------|--------|-----------|
| 1 | Add 8 Claude slash commands under `.claude/commands/`, one per scaffold skill | @mike | completed | this PR |
| 2 | Add `<!-- no-shim: claude -->` and `<!-- no-shim: codex -->` markers to 8 canonical SKILL.md files | @mike | completed | this PR |
| 3 | Update `.claude/commands/README.md` listing all 10 commands grouped by purpose | @mike | completed | this PR |
| 4 | Confirm `sync-agent-skills --check` reports 0 warnings | @mike | completed | this PR |
| 5 | Tighten `is_tier2_file()` in `scripts/openspec-triage.sh` to exclude `scripts/*.md` and `scripts/*.txt` | @mike | completed | this PR |
| 6 | Sanity-test the triage exclusion with synthetic Tier 1 vs Tier 2 diffs | @mike | completed | this PR |
| 7 | Add `scripts/check-commit-message.sh` enforcing conventional-commits prefix | @mike | completed | this PR |
| 8 | Wire the `check-commit-message` hook into `.pre-commit-config.yaml` on the `commit-msg` stage | @mike | completed | this PR |
| 9 | Sanity-test the commit-msg hook against 5 message shapes (accepts conventional, rejects non-conventional, accepts merge and revert) | @mike | completed | this PR |
| 10 | Write `docs/operations/branch-protection.md` with desired state, `gh api PUT` to apply, `gh api GET` to audit | @mike | completed | this PR |
| 11 | Link the runbook from `docs/operations/INDEX.md` | @mike | completed | this PR |
| 12 | Move `openspec/proposals/2026-05-16-enforcement-and-skill-rigor/` to `openspec/archive/` | @mike | completed | this PR |
| 13 | Update the archived proposal's frontmatter: status → accepted, add accepted_date / archived_date / merged_pr fields | @mike | completed | this PR |
| 14 | Update `openspec/README.md` to split current vs archived proposals; add the PR-4 proposal under current | @mike | completed | this PR |
| 15 | Run all 9 validators end-to-end; confirm PASS | @mike | completed | this PR |
| 16 | Run `pre-commit run --all-files`; confirm 18 pre-commit-stage hooks PASS | @mike | completed | this PR |
| 17 | Separately run `pre-commit run --hook-stage commit-msg --commit-msg-filename <msg>`; confirm the conventional-commits hook accepts a conforming message and rejects a non-conforming one | @mike | completed | this PR |

## Per-consumer integration tasks

None — `completion_state: architecture-complete`. No consumer must act.

## Dependencies between tasks

- Task 4 depends on tasks 1 and 2 (warnings cleared only after both commands and markers are in place).
- Task 6 depends on task 5 (test exercises the new classifier).
- Task 8 depends on task 7 (hook references the script).
- Task 9 depends on task 8 (test through pre-commit).
- Task 11 depends on task 10 (link can't exist without the file).
- Task 13 depends on task 12 (frontmatter edit follows the move).

## Cutover plan

No cutover. Each change is additive and independently revertible. The new commit-msg hook starts gating commits as soon as `.pre-commit-config.yaml` lands.

## Definition of done

`completion_state: architecture-complete`:

- [x] All architecture-side tasks resolved
- [x] `sync-agent-skills --check`: 0 errors, 0 warnings (was 16 warnings)
- [x] Healthcheck + openspec-triage + codeowners-check + pre-commit workflows green on `main` after merge
- [x] No ADR required (Tier 2)
- [x] No dependency records (no consumer impact)
- [x] Proposal status moved from `in_review` → `accepted` on merge
- [x] After PR merge: proposal directory moves to `openspec/archive/` (this proposal's own archive happens in the next PR — the recursion stops naturally)
