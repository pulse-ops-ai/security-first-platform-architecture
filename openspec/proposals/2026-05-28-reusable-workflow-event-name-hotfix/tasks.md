# OpenSpec Tasks: Reusable-workflow event-name guard hotfix

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | Revert `if:` gate in `.github/workflows/docs-healthcheck.yml` from `github.event_name == 'workflow_call'` to `inputs.architecture_ref != ''` | @mike | completed | this PR |
| 2 | Revert bash discriminator in same workflow's script-selection step | @mike | completed | this PR |
| 3 | Same two reverts in `.github/workflows/repo-healthcheck.yml` | @mike | completed | this PR |
| 4 | Update inline comments in both workflows to document **why** `inputs` is the correct discriminator and `github.event_name` is wrong in reusable workflows (prevents future re-introduction) | @mike | completed | this PR |
| 5 | Author OpenSpec proposal at `openspec/proposals/2026-05-28-reusable-workflow-event-name-hotfix/` (proposal / change / tasks) | @mike | completed | this PR |
| 6 | Run all 19 pre-commit hooks; confirm PASS | @mike | completed | this PR |
| 7 | Open PR with expedited-hotfix framing | @mike | completed | this PR |

## Definition of done

### Pre-merge (this PR must satisfy before merge)

- [x] `if:` gate on the dual-checkout step in both reusable workflows uses `inputs.architecture_ref != ''`.
- [x] Bash discriminator in the script-selection step in both reusable workflows uses `[[ -n "${{ inputs.architecture_ref }}" ]]`.
- [x] Inline comments document the bug history and the correct discriminator.
- [x] `architecture_ref: required: true` remains on the `workflow_call` input.
- [x] `pre-commit run --all-files`: 19/19 hooks PASS.
- [x] `openspec-triage.sh` classifies this PR as Tier 2 with proposal present.
- [x] Self-mode CI on this PR's own commits passes (the smoke test for self-mode behaviour).
- [x] No ADR required — mechanical bug revert, no architectural decision.
- [x] No new dependency records — `DEP-2026-05-24-001` already names the affected consumer; its `upstream_ref` will be bumped after `v0.1.1` is tagged.

### Post-merge (happens after this PR lands)

- [ ] Cut `v0.1.1` tag + release on the architecture repo's `main`. Release notes cite the bug, the cause, the fix, and the smoke-test plan (consumer-mode validated by `platform-edge`'s step-1 PR turning green after repinning).
- [ ] Tiny housekeeping PR: bump `portfolio/dependencies/2026-05-24-platform-edge-depends-on-security-first-platform-architecture-onboarding.md` `upstream_ref:` `v0.1.0` → `v0.1.1`. One-line diff.
- [ ] `platform-edge` repins: `security-first-adoption.md` `architecture_ref:` `v0.1.0` → `v0.1.1`; thin-caller workflows' `@ref` lines `@v0.1.0` → `@v0.1.1`. Push to the open step-1 PR. CI turns green ⇒ consumer-mode validated end-to-end.
- [ ] Archive this proposal: move `openspec/proposals/2026-05-28-reusable-workflow-event-name-hotfix/` → `openspec/archive/`; update frontmatter (`status: accepted`, `accepted_date`, `archived_date`, `merged_pr: <N>`). Per the `PR-N+1 archives PR-N` convention; likely combined with the `v0.1.1` housekeeping PR.

## Notes

- This is the **second** time PR #14's round-4 fix has surfaced an issue (the first was the silent-fallback concern that round-4 itself fixed). The lesson: defense-in-depth additions should be validated end-to-end before shipping, especially when they involve GitHub Actions context behaviour that the architecture repo's self-mode CI cannot exercise. A future improvement is a synthetic consumer-mode test harness inside the architecture repo (e.g., a workflow that uses the reusable workflow with a no-op caller) so consumer-mode breaks are caught in architecture-repo CI rather than at first-consumer time. Captured as a known follow-up; not blocking for this hotfix.
- The proposal is intentionally lighter than a normal Tier 2: the change is mechanical, the design choice is "restore the previously-correct discriminator," and there is a live consumer waiting on the fix. Reviewers should treat this as a hotfix.
- After `v0.1.1` ships, `v0.2.0` (which will include the diagramming PR #19 surface) becomes the next material consumer-visible bump.
