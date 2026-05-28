---
name: mermaid-diagram
description: Use when user asks to create, generate, draw, or design a sequence diagram, flowchart, state diagram, ER diagram, class diagram, or any diagram that should render inline in GitHub markdown without a separate image file. Mentions of mermaid, mermaidjs, sequenceDiagram, flowchart, stateDiagram, or "diagram in markdown" should trigger this skill.
---

# Mermaid diagram skill

Generate Mermaid diagrams as fenced ```` ```mermaid ```` blocks inside markdown files. Mermaid is the right tool when the diagram should render natively in GitHub without a separate `.png` / `.svg` file alongside, when the diagram is primarily sequential / flow-based, or when the diagram is short enough that hand-edited markdown is easier than maintaining a `.drawio` source.

For layered architecture diagrams, trust-zone overlays, or deployment topology, use the [`drawio`](../drawio/SKILL.md) skill instead — those need spatial layout that mermaid does not handle well. The format-choice rule lives in [`../../../standards/diagramming-conventions.md`](../../../standards/diagramming-conventions.md) §Format choice.

## Inputs

- Diagram intent and type — sequence, flowchart, state, ER, class, gitgraph, journey, gantt, timeline.
- Target markdown file (existing or new). Mermaid blocks live inside markdown, not in separate files.
- Optional: section heading to insert under, or replace.

## Procedure

1. **Pick the diagram type** matching the intent — see the [type-selection table](#diagram-type-selection) below.
2. **Generate the Mermaid syntax** for the chosen type. Use the architecture vocabulary mapping (colours, agent-as-client styling) from [`references/architecture-vocab.md`](references/architecture-vocab.md) when the diagram depicts a workspace concept (trust zones, layer interactions, agent routing).
3. **Embed in the target markdown file** as a fenced block:

   ````markdown
   ```mermaid
   sequenceDiagram
       participant U as User (Z0)
       participant K as Kong (L2)
       ...
   ```
   ````

4. **Add a one-line source-of-truth citation** below the diagram (per the standard):

   ````markdown
   *Source: `architecture/identity-and-authorization.md` · Last reviewed: 2026-05-28 by @mikegtech*
   ````

5. **Validate the syntax** by previewing it. Two options:
   - GitHub renders Mermaid in `.md` files natively — push and check the rendered view.
   - Local: install `@mermaid-js/mermaid-cli` (`npm i -g @mermaid-js/mermaid-cli`) and run `mmdc -i diagram.md -o diagram.svg` against an extracted block. Skip if the user has not installed it; do not auto-install.

6. **No separate file is produced.** Mermaid lives in the markdown. Do not also write a `.mmd` file alongside — that is a second source of truth that will drift.

## Output

- The target markdown file, with the new fenced ```` ```mermaid ```` block inserted at the requested location.
- A one-line source-of-truth citation below the diagram.
- Confirmation that the syntax is valid (via local CLI preview, GitHub render after push, or explicit Mermaid syntax validation).

## Diagram type selection

| Intent | Mermaid type | Use when |
|---|---|---|
| Request / response over time | `sequenceDiagram` | OAuth flow, agent-as-client routing, request lifecycle |
| Decision-branching flow | `flowchart TD` (top-down) or `flowchart LR` (left-right) | Onboarding decision tree, incident-response branching, OpenSpec tier triage |
| State machine | `stateDiagram-v2` | Dependency-record lifecycle (`open` → `in_progress` → `resolved`), OpenSpec proposal state |
| Entity relationships | `erDiagram` | Database schema, envelope claim relationships |
| Class hierarchy | `classDiagram` | Type hierarchies, interface composition |
| Time-based plan | `gantt` or `timeline` | Rollout schedule, deprecation windows |
| Git branch flow | `gitGraph` | Release strategy, branch protection model |
| User journey | `journey` | Onboarding experience, day-in-the-life flows |

If you are unsure between `sequenceDiagram` and `flowchart`: sequence has time on the Y axis (top-to-bottom); flowchart is decision logic with no time order. When in doubt, sequence is more honest for request flows.

## Style conventions for workspace diagrams

When depicting trust zones, layer interactions, or agent routing — anything in the visual vocabulary of [`../../../standards/diagramming-conventions.md`](../../../standards/diagramming-conventions.md) — apply the architecture-vocab mapping:

- Trust zone in participant labels: `User (Z0)`, `Kong (L2 / Z1)`, `OpenFGA (L4 / Z3)`, etc.
- Agent participants: `Claude / Codex / Automation (L8 → L1)` with a dashed line connecting back to L1, to visually enforce ADR-0002.
- Deviation callouts: use a `Note over` annotation in the sequence: `Note over A,B: DEV-002 — shared-secret instead of envelope`.

Full mapping with copy-pasteable snippets lives in [`references/architecture-vocab.md`](references/architecture-vocab.md).

## File naming

Mermaid does not produce standalone files — it lives inside markdown. Conventions:

- For ADRs: embed Mermaid directly inside the ADR markdown.
- For runbooks: embed under a `## Diagram` heading.
- For long-form architecture explainers: embed near the prose it illustrates.
- Do not create `.mmd` files. The markdown is the source of truth.

## Reference files (load on demand)

| File | Load when... |
|------|--------------|
| [`references/architecture-vocab.md`](references/architecture-vocab.md) | The diagram depicts a workspace concept (trust zones, layer interactions, agent-as-client, envelope crossing, deviation). Covers participant naming, layer→zone mapping, and copy-pasteable snippets aligned with the diagramming-conventions standard. |

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| GitHub renders the block as plain text | Missing or misspelled language tag | Confirm the fence starts with ```` ```mermaid ```` exactly (lowercase, no trailing space) |
| Diagram renders but missing arrows | Used `-->` where `->>` or `->>+` was needed in a sequence diagram | `->` is solid, `-->` is dashed; `->>` is solid arrow, `-->>` is dashed arrow |
| Long lines truncated | Mermaid wraps poorly on narrow screens | Break long participant names with `\n`; keep messages short |
| Parser error on `<` / `>` | Mermaid treats these as syntax | Escape: `&lt;` and `&gt;`, or wrap in backticks |
| Sequence diagram has wrong actor order | Mermaid orders by first appearance | Declare all participants with `participant` lines up-front, in the order you want |

## Anti-patterns

- **Producing a `.mmd` standalone file.** Mermaid lives in markdown. A separate file becomes a second source of truth that nothing references.
- **Embedding a sequence diagram where a flowchart would do.** Sequence implies time order; flowchart implies decision logic. Picking the wrong one confuses readers.
- **Dropping the source-of-truth citation.** Every diagram needs one. A Mermaid block without a citation is just as drift-prone as a `.drawio` file.
