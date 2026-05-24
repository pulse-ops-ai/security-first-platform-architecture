---
completion_state: architecture-complete
---

# OpenSpec Tasks: Align `repo-healthcheck` with the repo contract

Execution plan for [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Architecture-side tasks

| # | Task | Owner | Status | PR / link |
|---|------|-------|--------|-----------|
| 1 | Write `scripts/repo-healthcheck.sh` with mode auto-detection, Universal Floor checks, frontmatter validation, conditional floor, adapter consistency, and routing checks | @mike | completed | this PR |
| 2 | Smoke-test architecture-repo mode against this repo (expect PASS) | @mike | completed | this PR |
| 3 | Smoke-test consumer-repo mode against a synthetic fully-populated repo (expect PASS) | @mike | completed | this PR |
| 4 | Smoke-test consumer-repo mode against the template-shaped (unfilled) `security-first-adoption.md` (expect 19 errors: 7 scalars + 8 layers + 4 adapters) | @mike | completed | this PR |
| 5 | Smoke-test adapter mismatch (e.g., `claude_code: false` with `CLAUDE.md` present) | @mike | completed | this PR |
| 6 | Smoke-test missing `security-first-adoption.md` in consumer mode | @mike | completed | this PR |
| 7 | Rewrite `.agents/skills/repo-healthcheck/SKILL.md` to invoke the script and document finding categories | @mike | completed | this PR |
| 8 | Rewrite `.claude/commands/repo-healthcheck.md` to invoke the script and add the "don't add files to satisfy findings" guardrail | @mike | completed | this PR |
| 9 | Update `docs/operations/first-consumer-onboarding.md` step 10: replace multi-block manual workaround with script invocation + common-errors table | @mike | completed | this PR |
| 10 | Remove the "Known limitations of the validators" section + "Known false positives" guidance from the onboarding doc | @mike | completed | this PR |
| 11 | Add `repo-healthcheck.sh` to `scripts/README.md` catalog and local-run block | @mike | completed | this PR |
| 12 | Add `repo-healthcheck` hook to `.pre-commit-config.yaml` with floor/contract-relevant `files:` scope | @mike | completed | this PR |
| 13 | Run all 8 validators end-to-end (architecture, doc-indexes, skills, sync-agent-skills, infra-secrets, network-as-identity, openspec-triage, repo-healthcheck); confirm PASS | @mike | completed | this PR |
| 14 | Run `pre-commit run --all-files`; confirm 19 hooks PASS (18 pre-existing + 1 new repo-healthcheck) | @mike | completed | this PR |

## Per-consumer integration tasks

None — `completion_state: architecture-complete`. No consumer has onboarded yet. The first consumer (`trupryce`, in the next PR in its own repo) will use the aligned skill on first run; that PR is the de-facto integration test.

## Dependencies between tasks

- Tasks 2–6 depend on task 1 (script must exist before smoke tests).
- Tasks 7–10 depend on task 1 (skill/command/runbook reference the script).
- Task 12 depends on task 1 (hook references the script).
- Tasks 13–14 depend on all preceding tasks.

## Cutover plan

No cutover. The skill, command, and runbook are all updated in the same PR; there is no period during which they reference different versions. The pre-commit hook starts gating commits as soon as the PR merges.

## Definition of done

`completion_state: architecture-complete`.

### Pre-merge (verified in this PR)

- [x] All architecture-side tasks resolved (1–14)
- [x] All pre-existing validators PASS
- [x] New `repo-healthcheck.sh` PASSes against the architecture repo (architecture-repo mode)
- [x] Smoke-tested in consumer mode with three scenarios (populated, unfilled template, adapter mismatch, missing file)
- [x] `openspec-triage.sh` classifies this PR as Tier 2 and confirms proposal present
- [x] `pre-commit run --all-files` — all 19 hooks PASS
- [x] No ADR required (Tier 2)
- [x] No dependency records (no consumer impact yet)

### Post-merge (happens after this PR lands)

- [ ] Proposal `status:` moves from `in_review` → `accepted` (set by the merging maintainer or the next PR archive cleanup)
- [ ] Proposal directory moves to `openspec/archive/` in the next PR (per the established `PR-N+1 archives PR-N` pattern)
- [ ] First consumer onboarding PR (`trupryce`) uses the aligned skill on first run; surface any remaining gaps as follow-up issues
