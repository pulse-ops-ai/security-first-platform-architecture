# Diagram archetype templates

Starter templates — one per archetype in [`standards/diagramming-conventions.md`](../../../standards/diagramming-conventions.md) §Diagram archetypes. Copy the one whose **question** matches what you need to show, then replace the `<placeholders>` with your content. Each template already carries the correct palette, iconography, contrast-safe labels, title/subtitle/legend frame, and a source-of-truth footer stub — so you inherit the standard mechanically instead of rebuilding it.

## Pick by question

| Archetype | Question it answers | Template | Format |
|---|---|---|---|
| Trust-zone / layer architecture | "How does a request traverse the security boundaries?" | [`trust-zone-layer-architecture.drawio`](trust-zone-layer-architecture.drawio) | drawio |
| Deployment topology | "What runs where, and how do they talk?" | [`deployment-topology.drawio`](deployment-topology.drawio) | drawio |
| C4 System Context (L1) | "Who and what interacts with this system from the outside?" | [`c4-l1-system-context.drawio`](c4-l1-system-context.drawio) | drawio |
| C4 Container (L2) | "What containers make up the system, and how do they talk?" | [`c4-l2-container.drawio`](c4-l2-container.drawio) | drawio |
| Trust-zone sequence | "How does a request traverse the boundaries, with timing?" | [`trust-zone-sequence.md`](trust-zone-sequence.md) | Mermaid |
| C4 Dynamic | "What is the message order for a scenario, in C4 vocabulary?" | [`c4-dynamic.md`](c4-dynamic.md) | Mermaid |
| Decision tree / state machine | "What states / branches are possible?" | [`decision-tree.md`](decision-tree.md) | Mermaid |

## How to use

### drawio templates

```bash
# from your consuming repo (or the architecture repo)
cp <architecture-repo>/architecture/diagrams/templates/<archetype>.drawio \
   docs/diagrams/<your-name>.drawio          # architecture repo: architecture/diagrams/<your-name>.drawio
```

1. Open in drawio Desktop or `app.diagrams.net`. Replace every `<placeholder>`.
2. Re-export the paired SVG with the workspace flags (the `drawio` skill does this for you):

   ```bash
   drawio -x -f svg -e --embed-svg-fonts false -b 10 \
     -o docs/diagrams/<your-name>.svg docs/diagrams/<your-name>.drawio
   ```

   `-e` keeps the editable XML embedded; `--embed-svg-fonts false` keeps the file under the 500 KB pre-commit ceiling (browsers fall back to system fonts).
3. Fill in the footer's source-of-truth citation and `Last reviewed` / `Next review` dates, and add a row to your `diagrams/INDEX.md`.

### Mermaid templates

Copy the `.md`, keep the form you need (some have two), replace the placeholders, and fill in the **Source of truth** line. Mermaid renders inline in GitHub — no export step, no paired SVG.

## Rules these templates already follow

- **Contrast floor.** Layer-ribbon labels and box text use `#222222`; the per-layer colour identity is carried by the dashed stroke + tinted fill (standard §Layer ribbons, clarified in v0.2.1). No low-contrast colour-on-its-own-fill text.
- **One archetype per diagram.** The trust-zone templates never mix in C4 vocabulary and vice-versa (anti-mixing rule). When you need both lenses, make two diagrams and cross-link them.
- **C4 palette is distinct from the trust-zone palette** so the two archetypes can never be confused in one document.
- **Every diagram has** a title, subtitle, legend (when non-default styles are used), and a source-of-truth footer.

## When the templates are the wrong tool

- For the **canonical** workspace reference (the eight-layer control model), see [`../eight-layer-control-model.drawio`](../eight-layer-control-model.drawio) — that is a finished diagram, not a starter.
- For **per-shape styles** without a whole diagram, copy a swatch from the [`../styles/workspace.drawio`](../styles/workspace.drawio) style library instead.
- These templates are **vendor-neutral placeholders**. Profile-specific deployment diagrams (naming real vendors) belong in the consumer's repo, not here (standard §Anti-patterns).
