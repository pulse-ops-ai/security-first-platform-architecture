# OpenSpec Change: Diagramming Phase C.2 — archetype starter templates

Companion to [`proposal.md`](proposal.md).

## Files added

All under `architecture/diagrams/templates/`.

### Drawio templates (4 `.drawio` + 4 paired `.svg`)

| File | Archetype | Demonstrates |
|---|---|---|
| `trust-zone-layer-architecture.drawio` (+ `.svg`) | Trust-zone / layer architecture | Z0→Z4 bands (fills + per-zone strokes), downward request flow with orthogonal rounded edges, a future-layer ribbon using the paired fill + **`#222222` bold label** (v0.2.1 rule), legend, footer stub |
| `deployment-topology.drawio` (+ `.svg`) | Deployment topology | Trust-zone regions + iconography baseline (service rounded-rect, datastore cylinder, queue stadium, external dashed) + sync (solid) / async (dashed) connectors with white-bg labels |
| `c4-l1-system-context.drawio` (+ `.svg`) | C4 System Context (L1) | C4 palette (owned `#1168bd`, external `#999999`, person `#08427b`) with `[Person]` / `[Software System]` / `[External System]` type tags; agent-as-client person (ADR-0002) |
| `c4-l2-container.drawio` (+ `.svg`) | C4 Container (L2) | C4 system-boundary box, containers, a ContainerDb cylinder, an external system, protocol-tagged relationships |

SVGs exported `drawio -x -f svg -e -b 10 --embed-svg-fonts false`. Sizes 23–31 KB (well under the 500 KB `check-added-large-files` ceiling). Editable XML embedded.

### Mermaid templates (3 `.md`)

| File | Archetype | Demonstrates |
|---|---|---|
| `trust-zone-sequence.md` | Trust-zone sequence | `sequenceDiagram` + `(Zn)` participant notation + envelope issue/verify notes |
| `c4-dynamic.md` | C4 Dynamic | `C4Dynamic` + ADR-cited relationship labels + no-zone-notation anti-mixing reminder + a `drawio` fallback note |
| `decision-tree.md` | Decision tree / state machine | A `flowchart` decision tree **and** a `stateDiagram-v2` alternative |

### Supporting

| File | What it is |
|---|---|
| `README.md` | Pick-by-question table, copy/fill/export workflow (drawio + Mermaid), the rules the templates already follow, and "when the templates are the wrong tool" (canonical reference / swatch library / template) |

## Files modified

### `architecture/diagrams/INDEX.md`

- New "Archetype templates" subsection under Contents — a table of all seven templates with archetype + format, pointing at `templates/README.md`, and a note that templates are vendor-neutral placeholders exempt from the source-of-truth-footer requirement until copied and filled in.
- "Phase C scope and what comes next" updated: C.1 / C.3 marked shipped at `v0.2.0`, **C.2 marked shipped at `v0.3.0`**, D and E listed as still ahead.

## Files NOT modified

- `standards/diagramming-conventions.md` — the templates exemplify it (incl. the v0.2.1 clarifications this PR is stacked on); they do not change it.
- `.agents/skills/drawio/`, `mermaid-diagram/` — reference the standard; do not enumerate templates. No change.
- `templates/consuming-repo/` — gets a `docs/diagrams/` stub in Phase E, not here.
- `architecture/diagrams/styles/`, `eight-layer-control-model.drawio` — unchanged.

## Contract changes

**No contract surface changes.** Additive new directory of illustrative templates.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. The `v0.3.0` tag is cut in the v0.3.0 housekeeping PR after C.2 + D + E land. Consumers adopt at their next routine `architecture_ref` bump.

## Rollback

Delete `architecture/diagrams/templates/` and revert the `INDEX.md` edits → consumers fall back to authoring from the standard's prose + the swatch library (the pre-PR state). No diagram becomes invalid; nothing is irreversible.

## Verification

- All 4 drawio templates export to SVG without error (valid XML) and stay <35 KB.
- `bash scripts/validate-skills.sh`: PASS (no skill changes).
- `bash scripts/sync-agent-skills.sh --check`: PASS.
- `bash scripts/validate-doc-indexes.sh`: PASS (new templates referenced from `diagrams/INDEX.md`).
- `bash scripts/validate-architecture.sh`: PASS — templates are vendor-neutral (`<placeholder>` content, no real vendor names).
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 19/19 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present.
- **Manual:** open each `.svg` in a browser — confirm the palette, the contrast-safe labels, the legend, and the footer stub render correctly; confirm the C4 templates use distinct C4 colours (not trust-zone colours).
