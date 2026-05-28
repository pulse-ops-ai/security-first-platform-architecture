# Workspace style library

`workspace.drawio` is a **swatch-and-copy** style library. It is not a diagram of anything; it is a single-page drawio file containing one labelled rectangle (or arrow, or shape) per style defined in [`../../../standards/diagramming-conventions.md`](../../../standards/diagramming-conventions.md). Adopters open it, copy the swatch they need into their working diagram, rename the label, and inherit the correct visual style without having to memorise hex codes.

Paired SVG: [`workspace.drawio.svg`](workspace.drawio.svg). The `.svg` carries the full drawio XML embedded (per the export with `--embed-diagram`), so opening it in drawio recovers the editable source.

## How to use

1. Open `workspace.drawio` in drawio Desktop (or `app.diagrams.net`).
2. Find the swatch you want — trust zone, layer ribbon, connector type, shape, C4-archetype palette, envelope crossing, or text colour.
3. Select it. `Ctrl+C` (or right-click → Copy).
4. Switch to your working diagram. `Ctrl+V` to paste in place; the style transfers exactly.
5. Edit the label and resize as needed. The style stays.

This is faster and less error-prone than typing `fillColor=#dae8fc;strokeColor=#6c8ebf;…` by hand. It also guarantees you stay on the workspace palette — fixed Z0–Z4 colours, fixed layer-ribbon strokes, fixed text-colour rules.

## What the library covers

| Section | Swatches |
|---|---|
| 1. Trust zones (Z0 → Z4) | One labelled rectangle per zone with the standard's fill + stroke pair |
| 2. Layer ribbons (L1 → L8) | One labelled rectangle per layer with paired light fill + per-layer stroke |
| 3. Connectors | Default request flow, async, future / planned, agent-as-client lane (each shown as an A→B pair with the correct line style) |
| 4. Iconography | Service (rounded rect), datastore (cylinder), queue (stadium), external system (dashed rect), step-number badge, deviation marker + callout |
| 5. C4 archetype palette | Owned system, external system, component, person stencil — intentionally distinct from the trust-zone palette |
| 6. Envelope crossing (L6 → L7 / Z3 → Z4) | Thick arrow with the workspace-specific lock glyph placeholder |
| 7. Text colours | Primary `#222222` / secondary `#444444` on white / `#666666` on coloured fill / white-on-dark, each in a sample box |

## When the library is the wrong tool

The library is for **picking up workspace-correct styles for a new diagram you're authoring**. It is NOT:

- A reference diagram for the architecture. For that, see the actual architecture diagrams under [`../`](../) (e.g., `eight-layer-control-model.drawio`).
- A drawio shape library in the formal `*.xml` shape-library sense (which would let you drag shapes from the left sidebar). That's a Phase D enhancement; for now the swatch-and-copy workflow is sufficient.
- A specification document. The actual specification of the visual vocabulary lives in [`../../../standards/diagramming-conventions.md`](../../../standards/diagramming-conventions.md). The library is a faithful visual rendering of what that document specifies — if the two ever drift, the standard wins.

## Drift mitigation

`workspace.drawio` is reviewed quarterly alongside the standard:

- `last_reviewed:` 2026-05-28
- `next_review:` 2026-08-28

When the standard changes (new palette entry, new connector style, new archetype), the library is updated in the **same** PR that changes the standard — never lagged. Reviewers must verify the swatches still match.
