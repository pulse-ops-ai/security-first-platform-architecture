# Mermaid diagram

Author a Mermaid sequence, flowchart, state, ER, class, or related diagram inline in a markdown file. Canonical procedure: [`../../.agents/skills/mermaid-diagram/SKILL.md`](../../.agents/skills/mermaid-diagram/SKILL.md). Visual vocabulary (zone notation, layer-to-zone mapping, agent lane, envelope crossing, deviation callouts): [`../../standards/diagramming-conventions.md`](../../standards/diagramming-conventions.md) and [`../../.agents/skills/mermaid-diagram/references/architecture-vocab.md`](../../.agents/skills/mermaid-diagram/references/architecture-vocab.md).

## Usage

- `/mermaid-diagram <intent>` — pick the right diagram type and insert a fenced ```` ```mermaid ```` block in the most natural target markdown file.
- `/mermaid-diagram <type> <intent>` — force a specific type (`sequence`, `flowchart`, `state`, `er`, `class`, `gantt`, `journey`, `gitgraph`, `timeline`).
- `/mermaid-diagram in <file> <intent>` — insert the diagram into the named markdown file at a sensible location.

## When to use this vs `/drawio`

- **Mermaid**: time-based flows (sequence, journey, gantt), decision branches (flowchart), state machines, schema relationships. Renders inline in GitHub markdown; no separate file.
- **Drawio**: layered architecture, trust-zone overlays, deployment topology, anything spatial. Separate `.drawio` + `.svg` files in `docs/diagrams/` or `architecture/diagrams/`.

The full format-choice rule is in `standards/diagramming-conventions.md` §Format choice.

## Instructions

1. Follow the canonical `SKILL.md` procedure step-by-step.
2. If the diagram depicts a workspace concept, apply the trust-zone notation (`Participant (Zn)`) and the layer-to-zone mapping from [`references/architecture-vocab.md`](../../.agents/skills/mermaid-diagram/references/architecture-vocab.md).
3. Always add a one-line source-of-truth citation directly below the diagram block:

   ```markdown
   *Source: `<path-to-doc>` · Last reviewed: YYYY-MM-DD by @<handle>*
   ```

4. Validate that the syntax renders. If pushing to GitHub, the rendered view is the validation. Local `mmdc` is fine if installed but never auto-install.
5. Do not produce a `.mmd` file alongside the markdown — Mermaid lives in markdown only.

## Guardrails

- Sequence diagrams must label participants with their trust zone in parentheses: `Kong (L2 / Z1)`. Without this, the trust-crossing structure is invisible.
- The L6→L7 envelope crossing must include a `Note over` citing ADR-0003 — the most security-critical seam in the system gets explicit annotation, every time.
- Deviation callouts use `Note over A,B: DEV-NNN — <one-line>` with the deviation ID matching the consumer's `security-first-adoption.md` `deviations:` list. Full reason and compensating control stay in the adoption record, not on the diagram.
- Agents are clients. Sequence diagrams showing agents reaching services must route them through Kong (L2), not a direct line to L7. This visually enforces [ADR-0002](../../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md).
