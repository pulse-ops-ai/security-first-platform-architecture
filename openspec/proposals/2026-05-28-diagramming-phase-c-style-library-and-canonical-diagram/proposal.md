---
tier: 2
status: in_review
completion_state: architecture-complete
opened: 2026-05-28
target_decision_date: 2026-06-04
authors:
  - "@mike"
---

# OpenSpec Proposal: Diagramming Phase C — workspace style library + first canonical reference diagram

## Problem

The Phase A+B PR (#22) shipped a substantially expanded `standards/diagramming-conventions.md` (paired light-fills per layer, contrast floor, connector vocabulary, seven-archetype table, C4 palette, iconography, mandatory legend) but explicitly deferred two pieces of enterprise-grade tooling that the standard depends on:

1. **A workspace style artefact** so consumers do not type `fillColor=#dae8fc;strokeColor=#6c8ebf;…` by hand for every shape and instead inherit the workspace palette mechanically. Without this, "conformant to the standard" is a memory test — every consumer agent has to look up hex codes per-shape and is one typo away from drifting off the palette. The Phase A+B proposal called this "the largest enterprise-grade-tooling win" and the reason `v0.2.0` should not be tagged until it lands.
2. **At least one canonical reference diagram** in `architecture/diagrams/` produced *using the skill against the Phase-A+B standard*. The Phase A+B PR shipped the spec; this PR is the dog-food validation that the spec works in practice — that the palette is renderable, the contrast floor holds in a real diagram, and the archetype + source-of-truth + last-reviewed conventions read clearly when assembled into a real artefact.

Until both land, `v0.2.0` would be "spec for tools that don't exist yet" (the Phase A+B tasks.md called this out as the reason to delay the tag). This PR closes that gap.

## Proposed change

Ship two new artefacts plus the index/navigation glue around them, all under `architecture/diagrams/`:

### C.1 — Workspace style library at `architecture/diagrams/styles/workspace.drawio`

A single-page drawio file containing one labelled swatch per style defined in `standards/diagramming-conventions.md`: trust zones Z0–Z4 (fills + paired strokes), layer ribbons L1–L8 (paired light fills + per-layer strokes), connectors (default request flow, async, future / planned, agent-as-client lane), iconography (service / datastore / queue / external / step-badge / deviation marker), C4 archetype palette (owned / external / container / person), envelope-crossing glyph placeholder, and text-colour samples. Adopters open it, copy the swatch they need into their working diagram, rename the label, and inherit the correct style without re-typing hex codes. Paired SVG export (`workspace.drawio.svg`) preserves the embedded editable XML. A companion `styles/README.md` documents the 5-step copy/paste workflow, the coverage table, when the library is the wrong tool, and the quarterly review cadence (`last_reviewed: 2026-05-28`, `next_review: 2026-08-28`).

### C.3 — First reference diagram at `architecture/diagrams/eight-layer-control-model.drawio`

The canonical visual rendering of the eight-layer control model: trust-zone ribbons Z0→Z4, layer bands L1→L8 with paired fills, the L6→L7 / Z3→Z4 envelope crossing as the workspace's named L6→L7 trust contract, the agent-as-client lane, legend, source-of-truth footer (cites `architecture/control-layers.md`, `architecture/security-boundaries.md`, `ADR-0001`, `ADR-0002`, `ADR-0003`), and a `Last reviewed: 2026-05-28` footer date. Paired `.svg` with embedded editable XML. Vendor-neutral by design — describes the architecture, not a deployment. (Per the standard's anti-pattern, profile-specific topology diagrams stay in consumer repos.)

### Navigation glue

- `architecture/diagrams/INDEX.md` (new) — catalogues the reference diagrams (one-row table per diagram with archetype + source-of-truth + `Last reviewed` + `Next review`), the tooling (style library + README), the convention rules (every diagram MUST have a paired SVG and a source-of-truth footer), the drift-mitigation layers, and the in-scope vs deferred Phase-C scope (C.2 / D / E explicitly out).
- `architecture/INDEX.md` (modified) — adds a "Diagrams" section between Profiles and Related decisions pointing at `diagrams/INDEX.md` and cross-linking the standard.

### Deviation from the Phase A+B proposal's description of Phase C

The Phase A+B proposal described C.1 as a drawio **global-style XML file** to be imported via *Extras → Edit Diagram Style*. What this PR ships is a **swatch-and-copy style library** instead. Rationale:

- *Extras → Edit Diagram Style* sets the JSON style applied to **newly inserted unstyled shapes** in **one diagram at a time**. It does not import a vocabulary of named, ready-to-use shapes; it does not propagate across diagrams; consumers would still have to know "I want a Z3 fill — what does that look like?" and type or paste the hex codes for the shape they actually want.
- A swatch-and-copy library directly addresses the user task ("I need a Z3 zone box — give me one I can paste in and rename"). It is mechanical, copy-paste-correct, and visually obvious. Adopters get a workspace-correct shape with one keystroke; the wrong hex code is structurally impossible.
- A proper drawio shape library (`*.xml` with `<mxlibrary>` entries that appear in the left sidebar for drag-and-drop) is the eventual end-state and is tracked as a Phase D enhancement in `architecture/diagrams/styles/README.md` §"When the library is the wrong tool". This PR's swatch-and-copy artefact is the right intermediate step — it ships today, validates the palette, and is upgradeable without consumer churn.

The Phase A+B proposal's "deferred to Phase C" paragraph in `standards/diagramming-conventions.md` describes the file location accurately (`architecture/diagrams/styles/workspace.drawio`); only the workflow description ("import via *Extras → Edit Diagram Style*") drifted. Updating that one sentence in the standard is **not** in scope for this PR — it ships as part of the `v0.2.0` housekeeping PR alongside the proposal archive (per Phase A+B tasks.md §Post-merge). Capturing the deviation here in the Phase C proposal is sufficient for the record.

### Scope explicitly NOT in this PR

| Phase | What it is | Why deferred |
|---|---|---|
| **C.2** | Full set of starter `.drawio` templates per archetype (trust-zone, deployment-topology, C4 System Context, C4 Container, C4 Dynamic) under `architecture/diagrams/templates/` | Each template is its own dog-food exercise against the standard; bundling all six into one PR delays the C.1 + C.3 tag-gating pair. Tracked for `v0.2.1` or `v0.3.0`. |
| **D** | `scripts/validate-diagrams.sh` + pre-commit hook flagging stale `Last reviewed:` footers and rendered-SVG contrast-floor violations | Either a headless SVG-rendering check or an XML-metadata proxy; both have implementation gotchas worth getting right separately. The standard documents the floor; CI enforcement comes later. |
| **E** | Extend `templates/consuming-repo/` with a stub `docs/diagrams/` directory and starter `INDEX.md` | Consumer template change — better landed when its first consumer adopter is identified, so the template matches a real adoption flow rather than being a guess. |

These deferrals are documented in `architecture/diagrams/INDEX.md` §"Phase C scope and what comes next" so future contributors see them in the catalogue, not just buried in OpenSpec history.

## Alternatives considered

- **Ship Phase C.1, C.2, C.3, D, and E in one PR.** Maximal completeness for `v0.2.0`. Rejected because (a) Phase C.2's five templates each need an independent dog-fooding pass against the standard, which is the kind of work that surfaces fixes-to-the-standard mid-PR and grows scope unpredictably; (b) Phase D's validator design is non-trivial (contrast-floor check needs an SVG renderer or an XML metadata proxy — both have gotchas worth a dedicated proposal); (c) Phase E should land alongside a real first consumer to avoid template drift. The C.1 + C.3 pair is the minimum surface that lets `v0.2.0` ship as "standard + working tool + worked example" rather than "spec alone."
- **Ship only C.3 (the canonical diagram) and defer C.1 to a later PR.** Smaller PR. Rejected because without C.1, the second consumer authoring against this standard still has to type hex codes by hand and is exactly one typo away from drifting off-palette — the original Phase A+B motivation (palette is hard to apply correctly by memory) is unaddressed. C.3 alone would prove the standard is renderable; consumers still wouldn't have a tool.
- **Ship a drawio global-style XML file (per the literal Phase A+B description) instead of a swatch-and-copy library.** Matches the predecessor proposal verbatim. Rejected for the workflow-mismatch reasons documented in §Deviation above: *Extras → Edit Diagram Style* doesn't actually do what the predecessor proposal hoped it did. Captured here so the deviation is intentional, not an oversight.
- **Build the proper `<mxlibrary>` drag-and-drop shape library now instead of the swatch-and-copy intermediate.** Best long-term UX. Rejected for sequencing: a proper shape library is a larger lift (XML schema, icon rendering, drawio sidebar integration) and risks getting blocked on shape-rendering edge cases. The swatch-and-copy library is upgradeable to a proper shape library later (the shapes carry the same styles either way) — there is no consumer-churn cost to shipping the intermediate first. Tracked as Phase D enhancement in `styles/README.md`.

## Impact

- **Repos affected:** the architecture repo only in this PR. After `v0.2.0` is cut (in the follow-up housekeeping PR), consumers MAY adopt at their next routine `architecture_ref` bump.
- **Layers / profiles affected:** none. Visual tooling and reference diagram; no contract surface changes.
- **Standards affected:** none in this PR. The Phase A+B proposal's "deferred to Phase C" paragraph in `standards/diagramming-conventions.md` still describes the workflow as *Extras → Edit Diagram Style*; that one sentence will be updated in the `v0.2.0` housekeeping PR rather than here, since it is a post-hoc clarification rather than a Phase-C deliverable.
- **Skills affected:** none. The `drawio` skill already references the standard; it does not enumerate the workspace style library by path, so no skill text needs updating.
- **Templates affected:** none in this PR. `templates/consuming-repo/` gains a `docs/diagrams/` stub in Phase E.
- **Cross-repo contracts:** none. Additive new directory under `architecture/`.
- **Security-boundary impact:** none. The eight-layer canonical diagram visually depicts the existing Z0→Z4 / L1→L8 model from `control-layers.md`, `security-boundaries.md`, `ADR-0001`, `ADR-0002`, `ADR-0003`; it does not change any of them.

## Affected consumers (Tier 2/3 only)

_None._

This PR is opt-in additive. Consumers wishing to use the workspace style library copy swatches from it; consumers wishing to embed the canonical eight-layer diagram cross-link the rendered SVG. Neither is mandatory; no consumer is forced to migrate; no existing artefact in any consumer repo is invalidated. Per `team-os/cross-repo-governance.md` §Dependency-record linkage, a record is required only when a Tier 2 change "has downstream impact" — opt-in additive surface without forced migration does not qualify. This matches the Phase A+B PR (#22) precedent.

If a future PR adds enforcement (e.g., `validate-diagrams.sh` flagging diagrams that don't use the workspace palette), THAT PR opens dependency records per consumer; this one does not.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`.
- **`deprecation_window:`** `n/a` — additive change. Existing diagrams in consumer repos (e.g., `platform-edge`'s step-1) remain valid as-is per the Phase A+B grandfathering clause.
- **Migration steps:**
  1. Merge this PR. Phase C.1 + C.3 land on `main`; the workspace style library and eight-layer canonical diagram are reachable; `v0.2.0` is **not yet tagged**.
  2. **`v0.2.0` housekeeping PR** (separate, follows this PR) — cuts the `v0.2.0` tag at main HEAD, archives both `proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` and this proposal to `openspec/archive/`, updates the standard's "deferred to Phase C" paragraph to describe the swatch-and-copy workflow (replacing the *Extras → Edit Diagram Style* wording), and bumps any architecture-side dependency records to `v0.2.0` where appropriate.
  3. Consumers MAY adopt at their next routine `architecture_ref` bump. The `platform-edge` step-1 diagram MAY be polished against the workspace palette whenever convenient (likely folded into its step-2 PR).
  4. **Phase C.2 / D / E** ship as separate proposals in `v0.2.1` / `v0.3.0` cadence per the deferred-scope table above.

## Completion criteria

`completion_state: architecture-complete`

- `architecture/diagrams/styles/workspace.drawio` (+ paired `.svg`) exists and renders correctly.
- `architecture/diagrams/styles/README.md` exists and documents the swatch-and-copy workflow, coverage table, drift mitigation.
- `architecture/diagrams/eight-layer-control-model.drawio` (+ paired `.svg`) exists, renders correctly, contains the source-of-truth footer and `Last reviewed:` date.
- `architecture/diagrams/INDEX.md` exists and catalogues both artefacts with `Last reviewed` / `Next review` columns; documents the deferred C.2 / D / E scope.
- `architecture/INDEX.md` has a "Diagrams" section pointing at `diagrams/INDEX.md` and cross-linking the standard.
- All 19 pre-commit hooks pass.
- `openspec-triage.sh` classifies this PR as Tier 2 with proposal present (the `architecture/diagrams/` path triggers Tier 2; matches intent).
- No standard / skill / template changes — the Phase A+B PR already updated those for the new visual vocabulary.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete file additions and rationale per file.
- [`tasks.md`](tasks.md) — execution plan and definition of done.
- **Predecessor proposal:** [`../2026-05-28-diagramming-enterprise-upgrade-phase-a-b/`](../2026-05-28-diagramming-enterprise-upgrade-phase-a-b/) — Phase A+B (merged in PR #22); this proposal ships the C.1 + C.3 tag-gating pair it deferred.
- No ADRs — diagram tooling and visual artefacts are conventions, not foundational architectural trade-offs.
- No dependency records — opt-in additive; no consumer forced.
- **Eight-layer source-of-truth docs** — [`../../../architecture/control-layers.md`](../../../architecture/control-layers.md), [`../../../architecture/security-boundaries.md`](../../../architecture/security-boundaries.md), [`../../../docs/decisions/ADR-0001-adopt-eight-layer-control-model.md`](../../../docs/decisions/ADR-0001-adopt-eight-layer-control-model.md), [`../../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md`](../../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md), [`../../../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md`](../../../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md).
- **Diagramming-conventions standard** — [`../../../standards/diagramming-conventions.md`](../../../standards/diagramming-conventions.md). The library is a faithful rendering of what this standard specifies; if they ever drift, the standard wins.
