# architecture/diagrams/ — Index

Workspace-canonical diagrams that visually document the security-first platform architecture, plus the tooling that helps consumers produce conforming diagrams of their own.

The visual vocabulary, archetype catalog, contrast rules, and source-of-truth-citation requirements all live in [`../../standards/diagramming-conventions.md`](../../standards/diagramming-conventions.md). This directory is what that standard *looks like* in practice.

## Contents

### Reference diagrams

| Diagram | Archetype | Source of truth | Last reviewed | Next review |
|---|---|---|---|---|
| [`eight-layer-control-model.drawio`](eight-layer-control-model.drawio) + [`.svg`](eight-layer-control-model.drawio.svg) | Trust-zone / layer architecture | [`../control-layers.md`](../control-layers.md), [`../security-boundaries.md`](../security-boundaries.md), [`ADR-0001`](../../docs/decisions/ADR-0001-adopt-eight-layer-control-model.md), [`ADR-0002`](../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md), [`ADR-0003`](../../docs/decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md) | 2026-05-28 | 2026-08-28 |

The eight-layer canonical reference is **vendor-neutral** by design — it describes the architecture, not a specific deployment. Profile-specific diagrams (e.g., a self-hosted-vps deployment topology naming Kong / Traefik / Keycloak / OpenFGA) are explicitly NOT shipped from the architecture repo per the anti-pattern in `diagramming-conventions.md` §Anti-patterns. Consumers draw their own deployment diagrams in their own repos against the architecture-repo conventions.

### Tooling

| File | What it is |
|---|---|
| [`styles/workspace.drawio`](styles/workspace.drawio) + [`.svg`](styles/workspace.drawio.svg) | Swatch-and-copy style library covering trust zones, layer ribbons, connectors, iconography, C4 archetype palette, envelope-crossing glyph, and text colours. Adopters open it, copy a swatch, paste into their working diagram. See [`styles/README.md`](styles/README.md) for usage. |

### Archetype templates

Starter templates — one per archetype in `diagramming-conventions.md` §Diagram archetypes. Copy the one whose *question* matches what you need to show, replace the `<placeholders>`, re-export the SVG. See [`templates/README.md`](templates/README.md) for the pick-by-question table and usage.

| Template | Archetype | Format |
|---|---|---|
| [`templates/trust-zone-layer-architecture.drawio`](templates/trust-zone-layer-architecture.drawio) + [`.svg`](templates/trust-zone-layer-architecture.svg) | Trust-zone / layer architecture | drawio |
| [`templates/deployment-topology.drawio`](templates/deployment-topology.drawio) + [`.svg`](templates/deployment-topology.svg) | Deployment topology | drawio |
| [`templates/c4-l1-system-context.drawio`](templates/c4-l1-system-context.drawio) + [`.svg`](templates/c4-l1-system-context.svg) | C4 System Context (L1) | drawio |
| [`templates/c4-l2-container.drawio`](templates/c4-l2-container.drawio) + [`.svg`](templates/c4-l2-container.svg) | C4 Container (L2) | drawio |
| [`templates/trust-zone-sequence.md`](templates/trust-zone-sequence.md) | Trust-zone sequence | Mermaid |
| [`templates/c4-dynamic.md`](templates/c4-dynamic.md) | C4 Dynamic | Mermaid |
| [`templates/decision-tree.md`](templates/decision-tree.md) | Decision tree / state machine | Mermaid |

Templates are **vendor-neutral placeholders**, not finished diagrams; they are exempt from the source-of-truth-footer requirement until copied and filled in (the footer ships as a `YYYY-MM-DD` stub).

## Conventions

- Every diagram in this directory MUST have a paired rendered SVG (preferred) alongside the `.drawio` source, so readers without drawio can view it in GitHub. The skill auto-pairs on export with `--embed-diagram`, keeping the SVG itself editable.
- Every diagram MUST cite its source-of-truth doc(s) in a footer text element, with `Last reviewed:` and (implicitly via this `INDEX.md`) `Next review:` dates. The footer is checked at quarterly review.
- New diagrams are added with one row per diagram in this index. Diagrams that age out (next-review date passes without an update) are flagged in the next quarterly review; either re-review and re-date, or remove.

## Drift mitigation

This index is the catalog. Three additional layers of drift defence are described in `diagramming-conventions.md` §Drift mitigation:

1. Source-of-truth citation in every diagram's footer.
2. Quarterly review cadence (the `Last reviewed` / `Next review` columns above; each consumer's `docs/diagrams/INDEX.md` does the same).
3. [`scripts/validate-diagrams.sh`](../../scripts/validate-diagrams.sh) (shipped in `v0.3.0`) — a pre-commit hook that enforces a paired SVG and a fresh `Last reviewed:` footer per diagram, and runs a WCAG-AA contrast lint (warning by default, `--strict` to fail). `templates/` and `styles/` are excluded.

## Phase C scope and what comes next

Shipped so far:

- **C.1** (`v0.2.0`) — [`styles/workspace.drawio`](styles/workspace.drawio) (the style library).
- **C.3** (`v0.2.0`) — [`eight-layer-control-model.drawio`](eight-layer-control-model.drawio) (the canonical reference diagram).
- **C.2** (`v0.3.0`) — [`templates/`](templates/) starter templates for all seven archetypes (trust-zone / layer, deployment topology, C4 System Context, C4 Container, plus the Mermaid trust-zone sequence, C4 Dynamic, and decision-tree). See [`templates/README.md`](templates/README.md).

- **D** (`v0.3.0`) — [`scripts/validate-diagrams.sh`](../../scripts/validate-diagrams.sh) for paired-SVG, stale-footer, and contrast-floor enforcement (pre-commit hook).

Still ahead (separate OpenSpec proposal):

- **E** — extend `templates/consuming-repo/` with a stub `docs/diagrams/` and starter `INDEX.md`.
