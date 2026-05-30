---
completion_state: architecture-complete
---

# OpenSpec Tasks: Diagramming Phase D — `validate-diagrams.sh`

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | Write `scripts/validate-diagrams.sh` (paired-SVG + footer + contrast; mode auto-detect; changeset/full-scan; `--strict`/`--stale-days`) | @mike | completed | this PR |
| 2 | mawk-safe contrast math (hex→dec in bash, luminance in awk) | @mike | completed | this PR |
| 3 | Wire the `validate-diagrams` pre-commit hook (`pass_filenames: true`, `.drawio` under diagrams dirs) | @mike | completed | this PR |
| 4 | Flip `standards/diagramming-conventions.md` references (§Drift mitigation, §Contrast floor, §NOT-mandate) to "shipped in v0.3.0" | @mike | completed | this PR |
| 5 | Flip `architecture/diagrams/INDEX.md` (§Drift mitigation + Phase-C scope) | @mike | completed | this PR |
| 6 | Add `scripts/README.md` entry + running-locally line | @mike | completed | this PR |
| 7 | Write OpenSpec proposal (`proposal.md`, `change.md`, `tasks.md`) | @mike | completed | this PR |
| 8 | Add this proposal to `openspec/README.md` §Current proposals | @mike | completed | this PR |
| 9 | Verify exit codes (full scan 0, `--strict` 1, changeset-fresh 0) + contrast sanity values | @mike | completed | this PR |
| 10 | Confirm `pre-commit run --all-files`: 20/20 PASS | @mike | completed | this PR |
| 11 | Confirm `openspec-triage.sh origin/main`: Tier 2 with proposal present | @mike | completed | this PR |
| 12 | Open PR (base = C.2 branch) | @mike | completed | this PR |

## Definition of done

### Pre-merge

- [x] `scripts/validate-diagrams.sh` exists, executable, three checks, documented CLI.
- [x] Contrast math is mawk-safe (verified: `#82b366` on `#e8f0e3` = 2.10:1; `#ffffff` on `#1168bd` = 5.62:1).
- [x] Exit codes correct (full scan 0 / `--strict` 1 / changeset-fresh 0).
- [x] `templates/` and `styles/` excluded.
- [x] `validate-diagrams` pre-commit hook wired.
- [x] Standard / INDEX / scripts-README references flipped to "shipped in v0.3.0."
- [x] `openspec/README.md` §Current proposals lists this proposal.
- [x] `shellcheck` clean (via pre-commit).
- [x] `bash scripts/repo-healthcheck.sh`: PASS.
- [x] `pre-commit run --all-files`: 20/20 PASS.
- [x] `openspec-triage.sh`: Tier 2 with proposal present.
- [x] No ADR (tooling).
- [x] No dependency records (additive; hard checks restate existing MUSTs).

## Per-consumer integration tasks

**n/a** — no consumer is required to act. The hook no-ops when `docs/diagrams/` is absent; for consumers with diagrams it enforces rules the standard already mandated.

## Dependencies between tasks

- **Stacked on C.2** so the `templates/` exclusion is exercised against the real template files. Merge order: v0.2.1 (merged) → C.2 → D → E. GitHub retargets this PR's base to `main` as each predecessor merges.
- Prerequisite (merged): v0.2.1 clarifications (PR #26) — made the contrast rules self-consistent.

## Post-merge

- [ ] Part of the `v0.3.0` set (C.2 + D + E). The `v0.3.0` tag is cut in the v0.3.0 housekeeping PR after all three land; that PR also archives the C.2 / D / E proposals.
- [ ] **Recommended follow-up (separate PR):** refresh `architecture/diagrams/eight-layer-control-model.drawio` ribbon labels from per-layer stroke colours to `#222222` bold, so the canonical reference exemplifies v0.2.1 and clears the validator's 5 contrast warnings. Small visual change to the C.3 artefact; kept out of D to keep D a tooling PR.
- [ ] **Future enhancement:** pixel-accurate contrast on the rendered SVG (resolves real backgrounds, removes the white-bg heuristic) and the "diagram OR its cited doc changed" staleness cross-check. Both deferred from v1.

## Notes

- Contrast findings are **warnings by default** precisely because of the white-background heuristic (a standalone text cell over a dark shape would false-positive). `--strict` turns them into errors for repos/CI lanes that want the hard gate. The canonical eight-layer scan (5 warnings, grandfathered) is the concrete reason default-error would be wrong today.
- Uses GNU `date -d`; Linux CI/dev only. A coreutils note is in the script header for BSD/macOS users.
