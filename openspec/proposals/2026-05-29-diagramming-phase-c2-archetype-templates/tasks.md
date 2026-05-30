---
completion_state: architecture-complete
---

# OpenSpec Tasks: Diagramming Phase C.2 — archetype starter templates

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | `trust-zone-layer-architecture.drawio` + export `.svg` | @mike | completed | this PR |
| 2 | `deployment-topology.drawio` + export `.svg` | @mike | completed | this PR |
| 3 | `c4-l1-system-context.drawio` + export `.svg` | @mike | completed | this PR |
| 4 | `c4-l2-container.drawio` + export `.svg` | @mike | completed | this PR |
| 5 | `trust-zone-sequence.md` (Mermaid) | @mike | completed | this PR |
| 6 | `c4-dynamic.md` (Mermaid) | @mike | completed | this PR |
| 7 | `decision-tree.md` (Mermaid) | @mike | completed | this PR |
| 8 | `templates/README.md` (pick-by-question + usage) | @mike | completed | this PR |
| 9 | `architecture/diagrams/INDEX.md`: add Archetype-templates subsection; update Phase-C scope note | @mike | completed | this PR |
| 10 | Write OpenSpec proposal (`proposal.md`, `change.md`, `tasks.md`) | @mike | completed | this PR |
| 11 | Add this proposal to `openspec/README.md` §Current proposals | @mike | completed | this PR |
| 12 | Confirm all 4 drawio templates export to SVG without error, <35 KB | @mike | completed | this PR |
| 13 | Confirm `pre-commit run --all-files`: 19/19 PASS | @mike | completed | this PR |
| 14 | Confirm `openspec-triage.sh origin/main`: Tier 2 with proposal present | @mike | completed | this PR |
| 15 | Open PR (base = v0.2.1 clarifications branch) | @mike | completed | this PR |

## Definition of done

### Pre-merge

- [x] 4 drawio templates (+ paired SVG) and 3 Mermaid templates exist, one per archetype.
- [x] `templates/README.md` with pick-by-question table + usage.
- [x] Templates follow the v0.2.1-clarified rules (`#222222` bold ribbon labels; no archetype mixing; C4 palette distinct).
- [x] Drawio SVGs exported `-e --embed-svg-fonts false`, <35 KB, editable XML embedded.
- [x] `architecture/diagrams/INDEX.md` lists templates + updates the Phase-C scope note.
- [x] `openspec/README.md` §Current proposals lists this proposal.
- [x] `bash scripts/validate-skills.sh`: PASS.
- [x] `bash scripts/sync-agent-skills.sh --check`: PASS.
- [x] `bash scripts/validate-doc-indexes.sh`: PASS.
- [x] `bash scripts/validate-architecture.sh`: PASS (vendor-neutral).
- [x] `bash scripts/repo-healthcheck.sh`: PASS.
- [x] `pre-commit run --all-files`: 19/19 PASS.
- [x] `openspec-triage.sh`: Tier 2 with proposal present.
- [x] No ADR (templates are conventions).
- [x] No dependency records (opt-in additive).
- [x] No standard / skill changes.

## Per-consumer integration tasks

**n/a** — no consumer is required to integrate. Templates are opt-in copy-and-fill.

## Dependencies between tasks

- This PR is **stacked on the v0.2.1 clarifications branch** so the templates are authored against the clarified §Layer ribbons / §Step-number badges text. Merge v0.2.1 (its PR) before this one; GitHub retargets this PR's base to `main` after v0.2.1 merges.
- Tasks 1–4 (drawio sources) precede task 12 (export check).

## Post-merge

- [ ] Part of the `v0.3.0` set: ships alongside D (`validate-diagrams.sh`) and E (consumer `docs/diagrams/` stub). The `v0.3.0` tag is cut in the v0.3.0 housekeeping PR after C.2 + D + E land, which also archives the C.2 / D / E proposals.
- [ ] When D ships, run `validate-diagrams.sh` over `templates/` — the templates carry `YYYY-MM-DD` footer stubs by design, so D must treat `templates/` as exempt from the stale-footer check (template placeholders are not real dates). Noted as a D requirement.

## Notes

- The C4 templates use type-tagged filled boxes (`[Person]`, `[Container: …]`) rather than `mxgraph.c4.*` stencils for headless-CLI render-safety (a missing stencil renders blank). Standard C4 notation; renders identically everywhere. Swapping in the official stencils is a future enhancement once CLI-bundle availability is verified.
- Mermaid templates ship as `.md` with an embedded ```mermaid block (renders inline in GitHub); no paired SVG, per the standard's format-choice rule.
