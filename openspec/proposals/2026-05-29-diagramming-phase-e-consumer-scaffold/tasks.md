---
completion_state: architecture-complete
---

# OpenSpec Tasks: Diagramming Phase E — consuming-repo `docs/diagrams/` scaffold + CI enforcement

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | `templates/consuming-repo/docs/diagrams/INDEX.md` (starter index + enforcement note) | @mike | completed | this PR |
| 2 | `templates/consuming-repo/.gitignore` (drawio autosave + secret/editor/venv noise) | @mike | completed | this PR |
| 3 | `templates/consuming-repo/docs/INDEX.md`: add `diagrams/` to Sections | @mike | completed | this PR |
| 4 | `docs-healthcheck.yml`: add `validate-diagrams` step (two-output script-path step + guarded run + paths trigger), preserving the consumer-mode integrity property | @mike | completed | this PR |
| 5 | Write OpenSpec proposal (`proposal.md`, `change.md`, `tasks.md`) | @mike | completed | this PR |
| 6 | Add this proposal to `openspec/README.md` §Current proposals | @mike | completed | this PR |
| 7 | Verify validate-doc-indexes passes (new index referenced, not orphaned) | @mike | completed | this PR |
| 8 | Confirm `pre-commit run --all-files`: 20/20 PASS | @mike | completed | this PR |
| 9 | Confirm `openspec-triage.sh origin/main`: Tier 2 with proposal present | @mike | completed | this PR |
| 10 | Open PR (base = D branch) | @mike | completed | this PR |

## Definition of done

### Pre-merge

- [x] `templates/consuming-repo/docs/diagrams/INDEX.md` exists with how-to + conventions + enforcement note.
- [x] `templates/consuming-repo/.gitignore` exists (folds the drawio-autosave pattern).
- [x] `templates/consuming-repo/docs/INDEX.md` references `diagrams/`.
- [x] `docs-healthcheck.yml` runs `validate-diagrams` in self + consumer mode with the pre-v0.3.0 graceful skip; integrity property (no vendored script) preserved.
- [x] `openspec/README.md` §Current proposals lists this proposal.
- [x] `bash scripts/validate-doc-indexes.sh .`: PASS.
- [x] `bash scripts/repo-healthcheck.sh`: PASS.
- [x] `check-yaml` on `docs-healthcheck.yml`: PASS.
- [x] `pre-commit run --all-files`: 20/20 PASS.
- [x] `openspec-triage.sh`: Tier 2 with proposal present.
- [x] No ADR (scaffold + CI wiring).
- [x] No dependency records (additive; opt-in).
- [x] No standard / skill changes.

## Per-consumer integration tasks

**n/a** — no consumer is required to act. On a voluntary `architecture_ref` bump to `v0.3.0`, a consumer with diagrams gets CI enforcement; one without `docs/diagrams/` sees the step no-op. `platform-edge` stays green (paired SVG + footer present; contrast is a warning).

## Dependencies between tasks

- **Stacked on D** — E wires D's `validate-diagrams.sh` into consumer CI. Merge order: v0.2.1 (merged) → C.2 → D → E. GitHub retargets this PR's base as predecessors merge.

## Post-merge

- [ ] **Completes the `v0.3.0` set.** The v0.3.0 housekeeping PR (next) archives the C.2 / D / E proposals, updates `openspec/README.md`, and cuts the `v0.3.0` tag at main HEAD.
- [ ] When `platform-edge` next bumps to `v0.3.0`, its `docs-healthcheck` CI begins running `validate-diagrams` on `consumer-l1-l2-passthrough` — expected green (SVG + footer present). If the team wants the contrast warnings cleared, that pairs naturally with the recommended eight-layer refresh (a workspace-wide ribbon-label `#222222` pass).

## Notes

- The reusable-workflow edit is the only shared-CI-surface change in the v0.3.0 set, so it mirrors the proven `validate-doc-indexes` step exactly (same sparse-checkout, same self-vs-consumer discrimination, same "never vendor a tweaked script" integrity property) and adds a pre-v0.3.0 graceful skip. This is deliberately conservative given the reusable workflows' history (the PR #20 consumer-mode hotfix).
- Full-scan mode in CI (not `--strict`) means only the two hard checks (paired SVG, footer present) can fail a consumer's build; stale-footer and contrast are warnings. The changeset-mode hard gate on stale footers is the pre-commit hook's job, which consumers opt into separately.
