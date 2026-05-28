---
completion_state: architecture-complete
---

# OpenSpec Tasks: v0.2.0 housekeeping — cut tag, wording fix, skill fix, proposal archives

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | Branch `chore/v0.2.0-housekeeping` off main HEAD (commit `21feb5b`) | @mike | completed | this PR |
| 2 | Rewrite the `standards/diagramming-conventions.md` §What this standard does NOT mandate paragraph from "deferred Phase C / *Extras → Edit Diagram Style*" to a positive description of the swatch-and-copy library at `architecture/diagrams/styles/workspace.drawio` | @mike | completed | this PR |
| 3 | Update `.agents/skills/drawio/SKILL.md` §Procedure step 4 to recommend `--embed-svg-fonts false` for committed SVG | @mike | completed | this PR |
| 4 | Update `.agents/skills/drawio/SKILL.md` §Supported export formats — extend the SVG row Notes column | @mike | completed | this PR |
| 5 | Update `.agents/skills/drawio/SKILL.md` §Locating the CLI flags list — new entry for `--embed-svg-fonts <true/false>` | @mike | completed | this PR |
| 6 | Confirm `bash scripts/sync-agent-skills.sh --check`: PASS (no shim drift; shims delegate to canonical) | @mike | completed | this PR |
| 7 | `git mv openspec/proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b → openspec/archive/`; update its frontmatter to `status: accepted`, `accepted_date: 2026-05-28`, `archived_date: 2026-05-28`, `merged_pr: 22` | @mike | completed | this PR |
| 8 | `git mv openspec/proposals/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram → openspec/archive/`; update its frontmatter with `merged_pr: 23` | @mike | completed | this PR |
| 9 | Update `openspec/README.md` — remove PR #22 + PR #23 entries from §Current proposals, add them under §Archived proposals, add this housekeeping proposal under §Current proposals | @mike | completed | this PR |
| 10 | Write this OpenSpec proposal (`proposal.md`, `change.md`, `tasks.md`) | @mike | completed | this PR |
| 11 | Confirm `pre-commit run --all-files`: 19/19 PASS | @mike | pending | this PR |
| 12 | Confirm `bash scripts/openspec-triage.sh origin/main`: Tier 2 with proposal present | @mike | pending | this PR |
| 13 | Commit + push branch + open PR | @mike | pending | this PR |

## Definition of done

### Pre-merge (this PR must satisfy before merge)

- [x] `standards/diagramming-conventions.md` §What this standard does NOT mandate paragraph rewritten to describe the swatch-and-copy workflow.
- [x] `.agents/skills/drawio/SKILL.md` updated in three places (§Procedure step 4, §Supported export formats SVG row, §Locating the CLI flags list).
- [x] `openspec/archive/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` exists with `status: accepted`, `merged_pr: 22`.
- [x] `openspec/archive/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/` exists with `status: accepted`, `merged_pr: 23`.
- [x] `openspec/proposals/` no longer contains either of those directories.
- [x] `openspec/README.md` §Archived proposals lists both new entries with their merge-PR numbers; §Current proposals lists this housekeeping proposal.
- [ ] `bash scripts/validate-skills.sh`: PASS.
- [ ] `bash scripts/sync-agent-skills.sh --check`: PASS.
- [ ] `bash scripts/validate-doc-indexes.sh`: PASS.
- [ ] `bash scripts/validate-architecture.sh`: PASS.
- [ ] `bash scripts/repo-healthcheck.sh`: PASS.
- [ ] `pre-commit run --all-files`: 19/19 PASS.
- [ ] `bash scripts/openspec-triage.sh origin/main`: Tier 2 with proposal present.
- [x] No ADR required (wording + skill polish).
- [x] No dependency records (opt-in additive — see `proposal.md` §Affected consumers).
- [x] The `v0.2.0` tag is **NOT** cut in this PR's diff. The tag is cut after merge.

## Per-consumer integration tasks

**n/a** — no consumer is required to integrate.

The standard's wording fix tells consumers about a file that already exists (PR #23 shipped it); the drawio skill update is a recommendation that applies only to *new* SVG exports going forward; existing consumer diagrams are grandfathered (per PR #22's §Grandfathering and migration). Cutting the `v0.2.0` tag is a no-op for any consumer that does not choose to bump its `architecture_ref` pin.

## Dependencies between tasks

- Tasks 3, 4, 5 (drawio SKILL.md edits) must complete before task 6 (`sync-agent-skills.sh --check`).
- Tasks 7, 8 (proposal archive moves) must complete before task 9 (`openspec/README.md` update referencing the new archive paths).
- Tasks 2–10 must complete before task 11 (pre-commit) and task 12 (triage).
- Tasks 11, 12 block task 13 (open PR).

## Post-merge

This PR ships items 2–5 of the v0.2.0 release sequence; **item 1 (cut the tag) is a post-merge action**:

- [ ] `git tag v0.2.0 <merge-commit-sha-of-this-PR>` && `git push origin v0.2.0`.
- [ ] Draft the GitHub release for `v0.2.0` using the release-notes draft from `proposal.md` §"Release notes draft (for the `v0.2.0` tag cut after this PR merges)". Cite PR #22, PR #23, and this PR's merge number as the bundled surface.
- [ ] (Optional, low-stakes) bump `portfolio/dependencies/DEP-2026-05-24-001-platform-edge-onboarding.md` `upstream_ref` from `v0.1.1` to `v0.2.0` if `platform-edge` wants the new conventions before their next routine PR. Deferred per `proposal.md` §Out of scope; can ship as a separate `chore/dep-records-v0.2.0-pinning` PR when needed.

After `v0.2.0` is tagged, polish proposals ship as separate OpenSpec PRs:

- [ ] **Phase C.2** — full set of starter `.drawio` templates per archetype under `architecture/diagrams/templates/`. Could ship as `v0.2.1` or fold into `v0.3.0`. Tracked in `architecture/diagrams/INDEX.md` §"Phase C scope and what comes next".
- [ ] **Phase D** — `scripts/validate-diagrams.sh` for stale-footer enforcement and rendered-SVG contrast-floor checks. Closes the drift-mitigation loop sketched in `standards/diagramming-conventions.md` §Drift mitigation. Also the natural home for a programmatic enforcement of the `--embed-svg-fonts false` rule (e.g., flag any committed SVG over a configurable size threshold).
- [ ] **Phase E** — extend `templates/consuming-repo/` with a stub `docs/diagrams/` directory and starter `INDEX.md`. Best landed alongside a real first-consumer adopter.

## Notes

- The drawio skill update is documentation only; the shims delegate to canonical and `sync-agent-skills.sh --check` confirms no drift. No `.claude/skills/` or `.codex/skills/` file changes.
- The standard's wording fix lives in §What this standard does NOT mandate. The semantically-correct framing is "the standard does not mandate any particular import mechanism, but a swatch-and-copy library is available" — keeping it in this section preserves the standard's structure while accurately describing what ships.
- The release-notes draft in `proposal.md` intentionally does NOT list PR #20 (workflow event-name hotfix) or PR #21 (v0.1.1 housekeeping) — both already shipped under `v0.1.1`. `v0.2.0`'s release notes cover only the deltas since `v0.1.1`.
