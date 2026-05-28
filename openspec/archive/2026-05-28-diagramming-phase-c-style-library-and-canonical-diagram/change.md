# OpenSpec Change: Diagramming Phase C — workspace style library + first canonical reference diagram

Companion to [`proposal.md`](proposal.md).

## Files added

### `architecture/diagrams/styles/workspace.drawio` + `.svg`

- **Path.** `architecture/diagrams/styles/workspace.drawio`, paired SVG `architecture/diagrams/styles/workspace.drawio.svg`.
- **Before.** Did not exist; the Phase A+B PR (#22) deferred this artefact.
- **After.** Single-page drawio file with labelled swatches organised into seven sections:

  | # | Section | Swatches |
  |---|---|---|
  | 1 | Trust zones (Z0 → Z4) | One labelled rectangle per zone, standard's fill + stroke pair |
  | 2 | Layer ribbons (L1 → L8) | One labelled rectangle per layer with paired light fill + per-layer stroke |
  | 3 | Connectors | Default request flow, async, future / planned, agent-as-client lane (each shown as an A→B pair) |
  | 4 | Iconography | Service (rounded rect), datastore (cylinder), queue (stadium), external system (dashed rect), step-number badge, deviation marker + callout |
  | 5 | C4 archetype palette | Owned system, external system, container, person — intentionally distinct from trust-zone palette |
  | 6 | Envelope crossing (L6 → L7 / Z3 → Z4) | Thick arrow with workspace-specific lock glyph placeholder |
  | 7 | Text colours | Primary `#222222` / secondary `#444444` on white / `#666666` on coloured fill / white-on-dark, each in a sample box |

- **SVG export.** Generated with `drawio -x -f svg -e -b 20 --embed-diagram` so the SVG carries the editable drawio XML embedded. Opening the SVG in drawio recovers the source.
- **Rationale.** This is the C.1 deliverable — the "largest enterprise-grade-tooling win" called out in the Phase A+B proposal. Swatch-and-copy workflow (not the originally-described *Extras → Edit Diagram Style*); see proposal §Deviation for the rationale and §Alternatives considered for why we did not jump straight to a proper `<mxlibrary>` shape library.

### `architecture/diagrams/styles/README.md`

- **Path.** `architecture/diagrams/styles/README.md`.
- **Before.** Did not exist.
- **After.** Sections:
  - Intro: "swatch-and-copy style library, not a diagram of anything"; pointer to the standard as the spec.
  - **How to use** — 5-step Ctrl+C / Ctrl+V workflow.
  - **What the library covers** — the seven-row coverage table (matches the swatch sections above).
  - **When the library is the wrong tool** — three explicit non-uses (not an architecture reference diagram; not a formal `<mxlibrary>` drag-and-drop shape library — that's a Phase D enhancement; not a specification document — the standard wins if they drift).
  - **Drift mitigation** — `last_reviewed: 2026-05-28`, `next_review: 2026-08-28`; updated in the **same** PR that changes the standard, never lagged.
- **Rationale.** README pairs the swatch file with prose; the prose is what makes the 5-step workflow self-service. The "when this is the wrong tool" section preempts misuse (e.g., a consumer cargo-culting the swatch file into a deployment diagram).

### `architecture/diagrams/eight-layer-control-model.drawio` + `.svg`

- **Path.** `architecture/diagrams/eight-layer-control-model.drawio`, paired `eight-layer-control-model.drawio.svg`.
- **Before.** Did not exist; the Phase A+B PR (#22) deferred this artefact.
- **After.** Canonical visual rendering of the eight-layer control model:
  - Trust-zone columns Z0 → Z4 (fills + paired strokes from the standard's §Trust zones table).
  - Layer ribbons L1 → L8 (paired light fills + per-layer strokes from the standard's §Layer ribbons table).
  - L6 → L7 / Z3 → Z4 envelope crossing rendered per the standard's §Envelope crossing convention (named trust contract; NOT mesh identity, NOT re-called L4 — matches ADR-0003).
  - Agent-as-client lane (per ADR-0002 and the standard's §Agent-as-client lane).
  - Mandatory legend (`fontSize=14`, bold title) covering every non-default style used (matches the standard's §Title, legend, assumptions callout requirement).
  - Notes box (`fontSize=14`, bold title) calling out the vendor-neutrality scope.
  - Source-of-truth footer citing `architecture/control-layers.md`, `architecture/security-boundaries.md`, `ADR-0001`, `ADR-0002`, `ADR-0003`.
  - `Last reviewed: 2026-05-28` footer date (paired with `Next review: 2026-08-28` tracked in `architecture/diagrams/INDEX.md`).
- **Rationale.** This is the C.3 deliverable and the dog-food validation of the Phase A+B standard. Vendor-neutral by design — describes the architecture, not a deployment. Per the standard's anti-patterns, profile-specific topology diagrams stay in consumer repos.

### `architecture/diagrams/INDEX.md`

- **Path.** `architecture/diagrams/INDEX.md`.
- **Before.** Did not exist; the `architecture/diagrams/` directory did not exist before this PR.
- **After.** Catalogue of diagrams + tooling in this directory:
  - Intro: pointer to `standards/diagramming-conventions.md` as the authoritative visual-vocabulary spec; this directory is what that spec looks like in practice.
  - **Reference diagrams** table — one row per diagram, columns: archetype, source-of-truth doc(s), `Last reviewed`, `Next review`. Currently one row: `eight-layer-control-model.drawio` (+ `.svg`).
  - **Tooling** table — one row per tool. Currently: `styles/workspace.drawio` (+ `.svg`).
  - **Conventions** — every diagram MUST ship a paired rendered SVG; every diagram MUST cite source-of-truth doc(s) in a footer with `Last reviewed:` date; new diagrams add one row here; diagrams that age past `Next review` are flagged in the quarterly cadence.
  - **Drift mitigation** — three layers (source-of-truth footer; quarterly review cadence; future `validate-diagrams.sh` from Phase D).
  - **Phase C scope and what comes next** — documents what ships now (C.1 + C.3) and what is explicitly deferred (C.2 templates, D validator, E consumer-template stub).
- **Rationale.** Without an INDEX, future contributors have no canonical entry point for "where do I add a new reference diagram" and no visible deferred-scope record outside OpenSpec history.

## Files modified

### `architecture/INDEX.md`

- **Path.** `architecture/INDEX.md`.
- **Before.** Sections were Concepts / Identity & Authorization / Operations / Profiles / Related decisions.
- **After.** New "Diagrams" section inserted between Profiles and Related decisions:

  ```markdown
  ## Diagrams

  - [`diagrams/INDEX.md`](diagrams/INDEX.md) — workspace-canonical reference diagrams (currently: `eight-layer-control-model.drawio`) plus the swatch-and-copy `styles/workspace.drawio` style library. Visual vocabulary, archetypes, contrast rules, and drift mitigation are specified in [`../standards/diagramming-conventions.md`](../standards/diagramming-conventions.md).
  ```

- **Rationale.** The repo's top-level architecture index must point at the new diagrams directory or it's invisible from the agreed entry-point in `CLAUDE.md` (which directs readers to `architecture/INDEX.md`).

## Files NOT modified

- `standards/diagramming-conventions.md` — already has the "deferred to Phase C" paragraph from PR #22. The wording ("import via *Extras → Edit Diagram Style*") drifted from what we ended up shipping (swatch-and-copy). Updating that one sentence is out of scope for this PR; the `v0.2.0` housekeeping PR will fix it alongside the proposal archive (per Phase A+B tasks.md §Post-merge). Capturing the deviation in this proposal's §Deviation is sufficient for the record.
- `.agents/skills/drawio/SKILL.md` — already references the standard and does not enumerate the workspace style library by path. No skill text needs updating.
- `.agents/skills/mermaid-diagram/SKILL.md` and `references/` — unaffected; Phase A+B already added the C4 archetypes section to `architecture-vocab.md`.
- `.claude/skills/`, `.codex/skills/` — auto-synced; no canonical skill changes that require shim regeneration.
- `templates/consuming-repo/` — `docs/diagrams/` stub lands in Phase E with a real first-consumer adopter.
- `infra/`, `architecture/profiles/`, `team-os/`, `portfolio/` — unaffected.
- `openspec/proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` — NOT archived in this PR. Per Phase A+B tasks.md §Post-merge, both proposals are archived together in the `v0.2.0` housekeeping PR that follows this one.

## Contract changes

**No contract surface changes.** Strictly additive new directory under `architecture/`:

- No existing contract / standard / skill / template / dependency record is modified.
- No layer responsibility shift, no security-boundary change, no envelope-claim change.
- No CI gate added in this PR; `validate-diagrams.sh` is Phase D.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. Consumers adopt at their next routine `architecture_ref` bump.

The `v0.2.0` tag is **not** cut at this PR's merge. Per the Phase A+B proposal's revised sequencing, the tag is cut in a separate `v0.2.0` housekeeping PR that follows this one, archives both Phase A+B and Phase C proposals, and updates the standard's "deferred to Phase C" paragraph to match what shipped.

## Rollback

Each piece is independently reversible:

- Revert `architecture/diagrams/styles/workspace.drawio` + `README.md` → consumers fall back to typing hex codes per the standard's tables (the pre-PR state); no diagram becomes invalid.
- Revert `architecture/diagrams/eight-layer-control-model.drawio` + `.svg` → the eight-layer model is still specified in `control-layers.md` and `ADR-0001`; the diagram is illustrative, not normative.
- Revert `architecture/diagrams/INDEX.md` → only navigational glue is lost.
- Revert the `architecture/INDEX.md` Diagrams-section addition → only navigational glue is lost.

No rollback is irreversible.

## Verification

- `bash scripts/validate-skills.sh`: PASS (no canonical SKILL.md content changes).
- `bash scripts/sync-agent-skills.sh --check`: PASS (no shim regeneration needed).
- `bash scripts/validate-doc-indexes.sh`: PASS (new `diagrams/INDEX.md` is referenced from `architecture/INDEX.md`; tracked).
- `bash scripts/validate-architecture.sh`: PASS (eight-layer canonical diagram is vendor-neutral; no vendor-name leakage).
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 19/19 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present (`architecture/diagrams/` path triggers Tier 2; matches intent).
- **Visual validation (manual):** open `architecture/diagrams/eight-layer-control-model.drawio.svg` and `architecture/diagrams/styles/workspace.drawio.svg` in a browser or drawio. Confirm: trust-zone columns visible with paired strokes; layer ribbons readable on white; legend covers every non-default style; source-of-truth footer present; `Last reviewed: 2026-05-28` footer present on the eight-layer diagram.
