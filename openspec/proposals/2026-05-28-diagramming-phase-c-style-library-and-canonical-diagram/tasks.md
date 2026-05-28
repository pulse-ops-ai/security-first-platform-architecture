---
completion_state: architecture-complete
---

# OpenSpec Tasks: Diagramming Phase C — workspace style library + first canonical reference diagram

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | Create `architecture/diagrams/styles/workspace.drawio` swatch-and-copy library: trust zones, layer ribbons, connectors, iconography, C4 palette, envelope crossing, text colours | @mike | completed | this PR |
| 2 | Export paired `workspace.drawio.svg` with `--embed-diagram` (editable XML embedded) | @mike | completed | this PR |
| 3 | Write `architecture/diagrams/styles/README.md`: 5-step copy/paste workflow, coverage table, when-the-library-is-the-wrong-tool, drift mitigation with `last_reviewed` + `next_review` dates | @mike | completed | this PR |
| 4 | Create `architecture/diagrams/eight-layer-control-model.drawio`: Z0→Z4 columns, L1→L8 ribbons with paired fills, envelope crossing, agent-as-client lane, legend, notes, source-of-truth footer, `Last reviewed:` date | @mike | completed | this PR |
| 5 | Export paired `eight-layer-control-model.drawio.svg` with `--embed-diagram` | @mike | completed | this PR |
| 6 | Bump `legend_title` and `notes_title` font sizes from 12 to 14 for readability against neighbouring 14pt cell text | @mike | completed | this PR |
| 7 | Write `architecture/diagrams/INDEX.md`: reference-diagrams table, tooling table, conventions, drift mitigation, deferred-scope section (C.2 / D / E explicitly out) | @mike | completed | this PR |
| 8 | Add "Diagrams" section to `architecture/INDEX.md` between Profiles and Related decisions | @mike | completed | this PR |
| 9 | Write this OpenSpec proposal (`proposal.md`, `change.md`, `tasks.md`) including the §Deviation calling out swatch-and-copy vs *Extras → Edit Diagram Style* | @mike | completed | this PR |
| 10 | Append Phase C entry to `openspec/README.md` §Current proposals | @mike | completed | this PR |
| 11 | Confirm `pre-commit run --all-files`: 19/19 PASS | @mike | completed | this PR |
| 12 | Confirm `openspec-triage.sh`: Tier 2 with proposal present | @mike | completed | this PR |
| 13 | Open PR | @mike | pending | this PR |

## Definition of done

### Pre-merge (this PR must satisfy before merge)

- [x] `architecture/diagrams/styles/workspace.drawio` exists with all seven swatch sections.
- [x] `architecture/diagrams/styles/workspace.drawio.svg` exists with embedded editable XML.
- [x] `architecture/diagrams/styles/README.md` documents the swatch-and-copy workflow, coverage table, when-it-is-the-wrong-tool, and the quarterly review dates.
- [x] `architecture/diagrams/eight-layer-control-model.drawio` exists; vendor-neutral; renders correctly; carries the source-of-truth footer and `Last reviewed: 2026-05-28`.
- [x] `architecture/diagrams/eight-layer-control-model.drawio.svg` exists with embedded editable XML.
- [x] `architecture/diagrams/INDEX.md` catalogues both artefacts with `Last reviewed` / `Next review` columns and documents the deferred C.2 / D / E scope.
- [x] `architecture/INDEX.md` has a "Diagrams" section pointing at `diagrams/INDEX.md` and cross-linking the standard.
- [x] `openspec/README.md` §Current proposals lists this Phase C proposal.
- [x] `bash scripts/validate-skills.sh`: PASS.
- [x] `bash scripts/sync-agent-skills.sh --check`: PASS.
- [x] `bash scripts/validate-doc-indexes.sh`: PASS.
- [x] `bash scripts/validate-architecture.sh`: PASS (vendor-neutral).
- [x] `bash scripts/repo-healthcheck.sh`: PASS.
- [x] `pre-commit run --all-files`: 19/19 PASS.
- [x] `openspec-triage.sh`: Tier 2 with proposal present.
- [x] No ADR required (visual tooling and reference diagram are conventions, not foundational architectural trade-offs).
- [x] No dependency records (additive change; no consumer is forced — see proposal §Affected consumers).
- [x] No standard / skill / template content changes (the standard's "deferred to Phase C" wording fix is deferred to the `v0.2.0` housekeeping PR).

## Per-consumer integration tasks

**n/a** — no consumer is required to integrate.

The workspace style library is opt-in (consumers copy swatches when authoring new diagrams); the eight-layer canonical diagram is illustrative (consumers cross-link or embed at their discretion). Existing diagrams in consumer repos remain valid as-is per the Phase A+B grandfathering clause. `trupryce` ships no diagrams today; `platform-edge`'s step-1 diagram is grandfathered and MAY be polished against the workspace palette at the team's convenience.

## Dependencies between tasks

- Tasks 2 (workspace SVG export) and 5 (eight-layer SVG export) depend on the corresponding `.drawio` source files being finalised (tasks 1 + 6 respectively).
- Task 7 (`diagrams/INDEX.md`) depends on the diagram filenames being final.
- Task 9 (this proposal) depends on the §Deviation analysis (swatch-and-copy vs *Extras → Edit Diagram Style*), which is informed by tasks 1–3.
- Task 11 (`pre-commit`) blocks task 13 (open PR).

## Post-merge

This PR ships C.1 + C.3. It does **not** cut the `v0.2.0` tag and does **not** archive any proposals.

The follow-up `v0.2.0` housekeeping PR will:

- [ ] Update `standards/diagramming-conventions.md`'s "deferred to Phase C" paragraph to describe the **swatch-and-copy** workflow (replacing the *Extras → Edit Diagram Style* wording). The deviation rationale is captured in this proposal's §Deviation; the standard wording fix is housekeeping.
- [ ] Archive `openspec/proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` to `openspec/archive/`; update its frontmatter (`status: accepted`, `accepted_date`, `archived_date`, `merged_pr: 22`). Per the workspace's "PR-N+1 archives PR-N" convention; deferred to housekeeping per PR #22's own tasks.md.
- [ ] Archive this proposal to `openspec/archive/`; update its frontmatter (`status: accepted`, `accepted_date`, `archived_date`, `merged_pr: <N>`).
- [ ] Cut `v0.2.0` tag at main HEAD. Release notes cite Phase A+B + Phase C.1 + C.3 as the bundled surface ("standard + working tool + worked example").
- [ ] Bump architecture-side dependency records to `v0.2.0` where appropriate (`DEP-2026-05-24-001` platform-edge record currently targets `v0.1.1`; may stay there or bump — low-stakes either way).

After the `v0.2.0` housekeeping PR, polish proposals ship as separate OpenSpec PRs:

- [ ] **Phase C.2** — full set of starter `.drawio` templates per archetype under `architecture/diagrams/templates/`. Could ship as `v0.2.1` or fold into `v0.3.0`. Tracked in `architecture/diagrams/INDEX.md` §"Phase C scope and what comes next".
- [ ] **Phase D** — `scripts/validate-diagrams.sh` for stale-footer enforcement (>90 days when the diagram or its cited doc changes) and rendered-SVG contrast-floor checks. Closes the drift-mitigation loop sketched in `standards/diagramming-conventions.md` §Drift mitigation.
- [ ] **Phase E** — extend `templates/consuming-repo/` with a stub `docs/diagrams/` directory and starter `INDEX.md` referencing the workspace conventions. Best landed alongside a real first-consumer adopter to keep the template realistic.

## Notes

- The eight-layer canonical diagram is **vendor-neutral by design**. Profile-specific topology diagrams (e.g., a self-hosted-vps topology naming Kong / Traefik / Keycloak / OpenFGA) are explicitly NOT shipped from the architecture repo per the standard's anti-pattern. Consumers draw their own deployment diagrams against the architecture-repo conventions.
- Why swatch-and-copy instead of a proper `<mxlibrary>` drag-and-drop shape library: a proper shape library is a larger XML-schema + icon-rendering lift; the swatch-and-copy library is mechanically correct, ships today, and is upgradeable to a proper shape library later with no consumer-churn cost (the swatches carry the same styles either way). Tracked as a Phase D enhancement in `architecture/diagrams/styles/README.md`.
- The standard's contrast floor remains self-enforced in `v0.2.0`. The CI hook to enforce it programmatically lands in Phase D.
- "Phase C / D / E" labels in this proposal mirror the predecessor PR #22's labels; each polish phase will be its own OpenSpec proposal when staged. Splitting is a sequencing question for those future PRs, not this one.
