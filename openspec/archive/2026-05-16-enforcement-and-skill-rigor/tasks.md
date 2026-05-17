---
completion_state: architecture-complete
---

# OpenSpec Tasks: Enforcement and Skill Rigor

Execution plan for [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Architecture-side tasks

| # | Task | Owner | Status | PR / link |
|---|------|-------|--------|-----------|
| 1 | Add `scripts/check-network-as-identity.sh` with 5 heuristic categories; smoke-test against the architecture repo (expect 0 findings) | @mike | completed | this PR |
| 2 | Rewrite `.agents/skills/security-control-review/SKILL.md` to invoke the scanner; document categories and false-positive sources | @mike | completed | this PR |
| 3 | Rewrite `.agents/skills/architecture-review/SKILL.md` to invoke `validate-architecture.sh`; add layer-assignment checklist | @mike | completed | this PR |
| 4 | Rewrite `.agents/skills/cross-repo-impact-review/SKILL.md` with explicit sibling enumeration and concrete ripgrep commands | @mike | completed | this PR |
| 5 | Rewrite `.agents/skills/github-enterprise-ci-review/SKILL.md` with precise "stable job ID" definition and concrete commands | @mike | completed | this PR |
| 6 | Add `scripts/openspec-triage.sh` with Tier 1/2/3 classification and proposal-frontmatter validation | @mike | completed | this PR |
| 7 | Add `.github/workflows/openspec-triage.yml` triggering on architecture/standards/templates/skills/CI/AGENTS paths | @mike | completed | this PR |
| 8 | Rewrite `.agents/skills/openspec-change-triage/SKILL.md` to invoke the script | @mike | completed | this PR |
| 9 | Add `.github/workflows/codeowners-check.yml` with pinned `mszostok/codeowners-validator@v0.7.4` and placeholder-owner WARN | @mike | completed | this PR |
| 10 | Add `scripts/check-infra-secrets.sh` for 12-digit account IDs, ARNs, region defaults | @mike | completed | this PR |
| 11 | Wire `check-infra-secrets.sh` into `.pre-commit-config.yaml` | @mike | completed | this PR |
| 12 | Add `.github/dependabot.yml` for github-actions weekly | @mike | completed | this PR |
| 13 | Add `.github/workflows/pre-commit-autoupdate.yml` scheduled weekly | @mike | completed | this PR |
| 14 | Define "compensating control" in `architecture/deployment-profiles.md` with required fields and anti-patterns | @mike | completed | this PR |
| 15 | Update `scripts/README.md` to document the three new scripts | @mike | completed | this PR |
| 16 | Create `openspec/README.md` (floor entrypoint) and this proposal directory | @mike | completed | this PR |

## Per-consumer integration tasks

None — `completion_state: architecture-complete`. No consumer must act.

## Dependencies between tasks

- Task 2 depends on Task 1 (the scanner must exist before the skill references it).
- Task 8 depends on Task 6 (the script must exist before the skill references it).
- Task 11 depends on Task 10 (the hook reference depends on the script).

All other tasks are independent.

## Cutover plan

No cutover. Each change is additive and independently revertible.

## Definition of done

`completion_state: architecture-complete`.

> **Retro-fix note (added in PR #12, 2026-05-17):** the original DoD merged in PR #3 marked all items `[x]` regardless of whether they could be true while the PR was open. PR #12 split it into pre-merge and post-merge per the pattern introduced in PR #11. No content change to the historical record — only the checkbox-state corrected for accuracy.

### Pre-merge (verified in PR #3)

- [x] All architecture-side tasks resolved
- [x] Healthcheck workflows green on the architecture repo (`pre-commit`, `architecture-healthcheck`, `docs-healthcheck`, `skills-healthcheck`)
- [x] No ADR required (Tier 2)
- [x] Architecture-side dependency records: none required (no consumer impact)

### Post-merge (verified after PR #3 merged)

- [x] New workflows green on first run after merge (`openspec-triage`, `codeowners-check`) — confirmed by subsequent PR runs
- [x] Proposal status moved from `in_review` → `accepted` (verified at archive time)
- [x] Proposal directory moved to `openspec/archive/` once first PR-since-merge passed the new gates successfully (PR #8 was the archiving PR)
