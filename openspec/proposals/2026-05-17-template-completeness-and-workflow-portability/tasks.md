---
completion_state: architecture-complete
---

# OpenSpec Tasks: Template completeness + workflow portability

Execution plan for [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Architecture-side tasks

| # | Task | Owner | Status | PR / link |
|---|------|-------|--------|-----------|
| 1 | Refactor `scripts/validate-doc-indexes.sh` to accept optional target-path arg; default to script's own repo root | @mike | completed | this PR |
| 2 | Smoke-test the script in three modes (no arg, explicit `.`, explicit other path) | @mike | completed | this PR |
| 3 | Add `workflow_call:` trigger to `.github/workflows/docs-healthcheck.yml` with optional `architecture-ref` input; add dual-checkout logic | @mike | completed | this PR |
| 4 | Add `workflow_call:` trigger to `.github/workflows/pre-commit.yml` (no inputs needed) | @mike | completed | this PR |
| 5 | NEW `.github/workflows/repo-healthcheck.yml` — runs `repo-healthcheck.sh` in self-mode AND has `workflow_call:` trigger | @mike | completed | this PR |
| 6 | Add `templates/consuming-repo/.github/workflows/{repo-healthcheck,docs-healthcheck,pre-commit}.yml` thin callers | @mike | completed | this PR |
| 7 | Add `templates/consuming-repo/.github/CODEOWNERS` placeholder | @mike | completed | this PR |
| 8 | Add `templates/consuming-repo/.pre-commit-config.yaml` (consumer-portable subset) | @mike | completed | this PR |
| 9 | Add `templates/consuming-repo/.secrets.baseline` (empty starting baseline) | @mike | completed | this PR |
| 10 | Add `templates/consuming-repo/.gitleaks.toml` (narrow allowlist) | @mike | completed | this PR |
| 11 | Add `templates/consuming-repo/.claude/{skills,commands,agents}/README.md` adapter shim READMEs | @mike | completed | this PR |
| 12 | Update `docs/operations/first-consumer-onboarding.md` steps 2/3/9 to reflect the completed template | @mike | completed | this PR |
| 13 | Update `standards/repo-contract.md` with the "What the consumer template ships" section | @mike | completed | this PR |
| 14 | Archive PR #13's proposal: move `openspec/proposals/2026-05-17-repo-healthcheck-alignment/` to `openspec/archive/`; update frontmatter | @mike | completed | this PR |
| 15 | Update `openspec/README.md` current/archived lists | @mike | completed | this PR |
| 16 | Run all validators and pre-commit; confirm PASS | @mike | completed | this PR |

## Per-consumer integration tasks

None — `completion_state: architecture-complete`. trupryce will be the first user of the completed template + reusable workflows; integration happens in trupryce's own onboarding PR.

## Dependencies between tasks

- Tasks 3–5 depend on task 1 (the workflows reference the refactored script).
- Task 6 depends on tasks 3–5 (caller workflows reference the reusables that must exist).
- Tasks 12–13 depend on tasks 6–11 (runbook describes what the template ships).
- Task 16 depends on all preceding tasks.

## Cutover plan

No cutover. The change is additive: existing architecture-repo CI continues to work, new template files are net-new. The reusable workflows are usable immediately on merge; consumers that adopt them get the new path, others remain unaffected.

## Definition of done

`completion_state: architecture-complete`.

### Pre-merge (verified in this PR)

- [x] All architecture-side tasks resolved (1–16)
- [x] `validate-doc-indexes.sh` works in both self-mode and explicit-path mode
- [x] All pre-existing validators PASS
- [x] New `repo-healthcheck.yml` workflow YAML is valid
- [x] All four new template workflow YAMLs are valid (`check-yaml` passes)
- [x] `openspec-triage.sh` classifies this PR as Tier 2 with proposal present
- [x] `pre-commit run --all-files`: all 19 hooks PASS
- [x] No ADR required (Tier 2; the reusable-workflow contract is mechanical, not architectural)
- [x] No dependency records (no consumer impact yet)

### Post-merge (happens after this PR lands)

- [ ] Proposal `status:` moves from `in_review` → `accepted` (set by the merging maintainer or the next PR archive cleanup)
- [ ] Proposal directory moves to `openspec/archive/` in the next PR (per the established `PR-N+1 archives PR-N` pattern)
- [ ] trupryce onboarding PR (in trupryce's repo) consumes the new template; runbook gap-list shrinks to zero or surfaces new issues to address as follow-ups
