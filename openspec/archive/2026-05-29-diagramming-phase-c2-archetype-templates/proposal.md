---
tier: 2
status: accepted
completion_state: architecture-complete
opened: 2026-05-29
target_decision_date: 2026-06-05
accepted_date: 2026-05-29
archived_date: 2026-05-29
merged_pr: 27
authors:
  - "@mike"
---

# OpenSpec Proposal: Diagramming Phase C.2 — archetype starter templates

## Problem

The v0.2.0 diagramming kit defined **seven diagram archetypes** (`standards/diagramming-conventions.md` §Diagram archetypes) and shipped the vocabulary, the swatch-and-copy style library (C.1), and one finished canonical reference (C.3 — the eight-layer control model). What it did **not** ship is a starting point per archetype. A consumer who wants a C4 Container diagram, or a deployment topology, or a trust-zone sequence, today starts from a blank canvas and has to re-derive the palette, the iconography, the contrast-safe label colours, the title/subtitle/legend frame, and the source-of-truth footer from the standard's prose. That is exactly the "conformance is a memory test" friction C.1 set out to remove for *styles* — but it still exists for *whole diagrams*.

The platform-edge experience made this concrete: producing one trust-zone diagram against the standard took several iterations to get the ribbon-label contrast, the badge anchors, and the edge routing right (it drove the v0.2.1 clarifications). A consumer reaching for any of the other six archetypes would hit the same blank-canvas cost with no worked starting point. Phase C.2 — explicitly deferred from v0.2.0 — closes that gap.

## Proposed change

Ship `architecture/diagrams/templates/` with one **starter template per archetype** (all seven) plus a `README.md`. Each template is a vendor-neutral skeleton with `<placeholders>` that already carries the correct palette, iconography, contrast-safe labels, archetype frame, and a footer stub — so a consumer copies it, replaces the placeholders, re-exports, and is conformant by construction.

### Templates (7)

**Drawio (4)** — each ships a paired `.svg` (exported `-e --embed-svg-fonts false`, editable XML embedded, <35 KB):

- `trust-zone-layer-architecture.drawio` — Z0→Z4 bands + a future-layer ribbon that exemplifies the v0.2.1 `#222222`-bold label rule; downward request flow; legend; footer stub.
- `deployment-topology.drawio` — trust-zone regions + the iconography baseline (service rounded-rect, datastore cylinder, queue stadium, external dashed) + sync/async connectors.
- `c4-l1-system-context.drawio` — C4 palette (owned dark-blue, external gray, person navy) with the `[Person]` / `[Software System]` / `[External System]` type tags; the owned system as a black box.
- `c4-l2-container.drawio` — C4 system-boundary box + containers + a ContainerDb cylinder + an external system, with protocol-tagged relationships.

**Mermaid (3)** — markdown with an embedded ```mermaid block, no paired SVG (renders inline in GitHub):

- `trust-zone-sequence.md` — `sequenceDiagram` with the `(Zn)` participant notation and the envelope-issuance/verification notes.
- `c4-dynamic.md` — `C4Dynamic` with ADR-cited relationship labels and the no-zone-notation anti-mixing reminder.
- `decision-tree.md` — a `flowchart` decision tree plus a `stateDiagram-v2` alternative.

### Supporting

- `templates/README.md` — a pick-by-question table, copy/fill/export instructions, the rules the templates already follow, and "when the templates are the wrong tool" (canonical reference vs. swatch library vs. template).
- `architecture/diagrams/INDEX.md` — new "Archetype templates" subsection + the Phase-C scope note updated (C.2 now shipped; D and E still ahead).

### Render-safety note

The C4 templates represent persons and systems as **filled rounded rectangles with C4 type tags** (`[Person]`, `[Container: …]`) rather than `mxgraph.c4.*` stencils, because stencil availability in the headless drawio CLI export is not guaranteed and a missing stencil renders blank. The type-tagged-box form is standard C4 notation, renders identically everywhere, and is what a consumer can edit without the C4 shape library installed. A future enhancement may swap in the official stencils once CLI-bundle availability is verified.

## Alternatives considered

- **Ship only the four drawio templates; defer the three Mermaid ones.** Smaller PR. Rejected: the standard defines seven archetypes; shipping four leaves the "where do I start?" gap open for exactly the archetypes (sequence, dynamic, decision tree) that are *quickest* to template because they are text. Completeness is cheap here.
- **Put the templates in `templates/` at repo root (next to `templates/consuming-repo/`).** Consistent with the other templates. Rejected: diagram templates are diagram-domain artefacts that belong beside the diagrams they exemplify and the style library they share a palette with (`architecture/diagrams/`), and the `drawio` skill + `diagrams/INDEX.md` already root there. `templates/consuming-repo/` gets a `docs/diagrams/` *stub* in Phase E that points back here.
- **Make the templates richly worked examples (a realistic system) rather than `<placeholder>` skeletons.** More immediately impressive. Rejected: a worked example invites copy-paste of the example's content; a placeholder skeleton makes the consumer think about *their* system. The canonical eight-layer reference already serves the "worked example" need.
- **Use the official `mxgraph.c4` stencils for the C4 templates.** Most authentic C4 look. Rejected for now on render-safety (see note above); revisit when CLI-bundle stencil availability is verified.

## Impact

- **Repos affected:** the architecture repo only. After `v0.3.0` is tagged, consumers may adopt at their next routine `architecture_ref` bump.
- **Layers / profiles affected:** none.
- **Standards affected:** none. The templates *exemplify* `standards/diagramming-conventions.md` (including the v0.2.1 clarifications); they do not change it.
- **Skills affected:** none. The `drawio` / `mermaid-diagram` skills already reference the standard; they do not enumerate templates.
- **Templates affected:** new `architecture/diagrams/templates/` directory. `templates/consuming-repo/` is untouched here (Phase E).
- **Cross-repo contracts:** none. Additive new directory.
- **Security-boundary impact:** none. The templates illustrate; they do not enforce.

## Affected consumers (Tier 2/3 only)

_None._

Opt-in additive. Consumers may copy a template when authoring a new diagram; nothing is mandatory and no existing artefact is invalidated. Per `team-os/cross-repo-governance.md` §Dependency-record linkage, no dependency record is required. Matches the C.1 / C.3 precedent (PR #23).

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`.
- **`deprecation_window:`** `n/a` — additive.
- **Migration steps:**
  1. Merge this PR (stacked on the v0.2.1 clarifications — see §Linked artifacts). The templates land under `architecture/diagrams/templates/`.
  2. `v0.3.0` is cut in the v0.3.0 housekeeping PR after C.2 + D + E land (same dog-food-then-tag pattern as v0.2.0).
  3. Consumers adopt at their next routine `architecture_ref` bump.

## Completion criteria

`completion_state: architecture-complete`

- `architecture/diagrams/templates/` contains 4 `.drawio` (+ paired `.svg`) and 3 Mermaid `.md` templates, one per archetype, plus `README.md`.
- Each drawio template renders (SVG exported, valid XML) and stays under the 500 KB ceiling.
- Templates follow the v0.2.1-clarified rules (`#222222` bold ribbon labels; no archetype mixing; C4 palette distinct from trust-zone palette).
- `architecture/diagrams/INDEX.md` lists the templates and updates the Phase-C scope note.
- All 19 pre-commit hooks pass.
- `openspec-triage.sh`: Tier 2 with proposal present.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — file-by-file detail.
- [`tasks.md`](tasks.md) — execution plan.
- **Stacked on:** the v0.2.1 clarifications proposal (`2026-05-29-diagramming-conventions-v0.2.1-clarifications`) — the templates are authored against the clarified §Layer ribbons / §Step-number badges text, so this PR's base is that branch. Merge v0.2.1 first.
- **Part of the v0.3.0 set:** C.2 (this), D (`validate-diagrams.sh`), E (consumer-template `docs/diagrams/` stub).
- No ADRs — templates are conventions, not foundational trade-offs.
- No dependency records — opt-in additive.
- **C4 references:** [c4model.com](https://c4model.com/), [drawio C4 stencils](https://www.drawio.com/blog/c4-modelling), [Mermaid C4 syntax](https://mermaid.js.org/syntax/c4.html).
