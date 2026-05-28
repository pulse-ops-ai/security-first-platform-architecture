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

## Conventions

- Every diagram in this directory MUST have a paired rendered SVG (preferred) alongside the `.drawio` source, so readers without drawio can view it in GitHub. The skill auto-pairs on export with `--embed-diagram`, keeping the SVG itself editable.
- Every diagram MUST cite its source-of-truth doc(s) in a footer text element, with `Last reviewed:` and (implicitly via this `INDEX.md`) `Next review:` dates. The footer is checked at quarterly review.
- New diagrams are added with one row per diagram in this index. Diagrams that age out (next-review date passes without an update) are flagged in the next quarterly review; either re-review and re-date, or remove.

## Drift mitigation

This index is the catalog. Three additional layers of drift defence are described in `diagramming-conventions.md` §Drift mitigation:

1. Source-of-truth citation in every diagram's footer.
2. Quarterly review cadence (the `Last reviewed` / `Next review` columns above; each consumer's `docs/diagrams/INDEX.md` does the same).
3. A future `scripts/validate-diagrams.sh` (Phase D) that flags stale footer dates when the diagram or its cited doc changes, plus contrast-floor checks against the rendered `.svg`.

## Phase C scope and what comes next

This index ships with Phase C of the diagramming kit:

- **C.1** — [`styles/workspace.drawio`](styles/workspace.drawio) (the style library).
- **C.3** — [`eight-layer-control-model.drawio`](eight-layer-control-model.drawio) (the first reference diagram, dog-fooding the skill against the Phase-A+B standard).

Deferred to a separate PR or `v0.2.1` / `v0.3.0`:

- **C.2** — full set of starter templates per archetype (trust-zone, deployment-topology, C4 System Context, C4 Container, C4 Dynamic) under `templates/` here.
- **D** — `scripts/validate-diagrams.sh` for stale-footer and contrast-floor enforcement.
- **E** — extend `templates/consuming-repo/` with a stub `docs/diagrams/` and starter `INDEX.md`.
