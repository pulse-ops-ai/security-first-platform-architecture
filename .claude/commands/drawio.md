# Drawio diagram

Author or export a `.drawio` diagram. Canonical procedure: [`../../.agents/skills/drawio/SKILL.md`](../../.agents/skills/drawio/SKILL.md). Visual vocabulary (zone colours, layer ribbons, agent-as-client lane, deviation markers): [`../../standards/diagramming-conventions.md`](../../standards/diagramming-conventions.md).

## Usage

- `/drawio <intent>` — write a `.drawio` file matching the intent (no export).
- `/drawio png|svg|pdf <intent>` — also export to the requested format with embedded XML.
- `/drawio update <existing-file> <change>` — edit an existing diagram in place.

## Instructions

1. Follow the procedure in the canonical `SKILL.md` step-by-step. The seven-step flow (generate XML → write file → optional postprocess → optional export → open → add footer → update INDEX) is non-negotiable for architectural diagrams.
2. If the diagram depicts a workspace concept (trust zones, layer interactions, agent routing, envelope crossing, deviation), apply the visual vocabulary from the standard. Zone colours are workspace-wide and not negotiable.
3. Place files under `architecture/diagrams/` in the architecture repo or `docs/diagrams/` in a consuming repo. Match the naming convention (lowercase-hyphenated, scope-prefixed).
4. Every architectural diagram **must** have a footer citing its source-of-truth doc and the last-reviewed date. The standard rejects diagrams without one.
5. After producing the diagram, update the relevant `INDEX.md` entry with `last_reviewed:` (today) and `next_review:` (today + 90 days).

## Guardrails

- Do not invent zone colours or layer-ribbon strokes. The vocabulary is in the standard; treat it as fixed.
- Do not draw agents on a back-channel into L7 — per [ADR-0002](../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md) they are always clients. A diagram showing otherwise is a finding, not a stylistic choice.
- Do not commit unrendered `.drawio` files to `docs/diagrams/` or `architecture/diagrams/`. The standard requires a paired `.svg` (preferred) or `.png` so readers without drawio can see the diagram.
- For one-off scratch diagrams outside those directories, exporting and deleting the source `.drawio` is fine — the exported PNG/SVG/PDF retains the embedded XML.
- Reference files (`references/edge-routing.md`, `references/x86_64-install.md`) are load-on-demand. Do not preload them unless the symptom (bad routing) or environment (x86_64 install) calls for it.
