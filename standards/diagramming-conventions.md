# Diagramming conventions

A shared visual vocabulary for architecture, trust-zone, deployment-topology, sequence, and system-context diagrams produced by repos in this workspace. Without conventions, every consumer invents its own colours, shapes, and layer markings — cross-repo audits get harder, not easier.

The skills that produce diagrams against this vocabulary live in [`../.agents/skills/drawio/`](../.agents/skills/drawio/SKILL.md) and [`../.agents/skills/mermaid-diagram/`](../.agents/skills/mermaid-diagram/SKILL.md). This file is the **what** (vocabulary + conventions); those skills are the **how** (tool wiring + production).

## Format choice — when to use which

| Diagram type | Format | Why |
|---|---|---|
| Layered architecture, trust-zone overlays, deployment topology, dependency graphs | **Drawio** (`.drawio` + rendered `.svg` / `.png`) | Multi-layer spatial work needs proper boxes, lanes, and corridor routing. Drawio handles it; Mermaid does not. |
| C4 System Context (Level 1), C4 Container (Level 2) | **Drawio preferred** when the diagram needs spatial layout with multiple containers / external systems; **Mermaid `C4Context` / `C4Container` acceptable** when the diagram is small enough to render usefully inline in a markdown doc. Either form ships an editable source-of-truth. | Drawio scales spatially better; Mermaid wins on inline rendering. The Mermaid skill reference ([`../.agents/skills/mermaid-diagram/references/architecture-vocab.md`](../.agents/skills/mermaid-diagram/references/architecture-vocab.md) §C4 archetypes in Mermaid) has working examples; the drawio C4 stencil library is at [drawio.com/blog/c4-modelling](https://www.drawio.com/blog/c4-modelling). |
| Trust-zone sequence (request flow, OAuth/OIDC, agent-as-client routing, incident timeline) | **Mermaid** `sequenceDiagram` with trust-zone participant notation per [`../.agents/skills/mermaid-diagram/references/architecture-vocab.md`](../.agents/skills/mermaid-diagram/references/architecture-vocab.md) §Trust-zone notation in participants. | Sequence diagrams render natively in GitHub markdown; trust-zone notation in participant labels keeps the security-boundary structure visible without colour. |
| C4 Dynamic (sequence in C4 vocabulary) | **Mermaid** `C4Dynamic`. Per the anti-mixing rule, C4 Dynamic does NOT carry trust-zone notation in the visual; cite ADRs by ID in relationship labels instead. | C4 vocabulary stays consistent across L1/L2/L3 and Dynamic; mixing zones would violate the archetype boundary. |
| Whiteboard sketch, RFC ideation, workshop output | Either is fine; not yet standardised | Don't optimise prematurely — promote to drawio/mermaid only if the sketch becomes a recurring reference. |

`.drawio` files **must** be paired with a rendered `.svg` (preferred) or `.png` alongside, so readers without drawio can see the diagram in GitHub. The skill handles export.

## Diagram archetypes

Use the archetype that matches the question the diagram answers. Mixing archetypes in one diagram is the most common source of confusion.

| Archetype | Question it answers | Format | Vocabulary |
|---|---|---|---|
| **Trust-zone / layer architecture** | "How does a request traverse the security boundaries?" | Drawio | Trust-zone fills (Z0–Z4) + layer ribbons (L1–L8). The signature workspace diagram. |
| **Deployment topology** | "What runs where, and how do they talk to each other?" | Drawio | Trust-zone fills + service shapes + connectors. Often overlaid with layer ribbons. |
| **C4 System Context (Level 1)** | "Who and what interacts with this system from the outside?" | Drawio | C4 palette (owned-system dark blue, external systems gray, persons). Zoom level: the system as a black box. |
| **C4 Container (Level 2)** | "What major containers (apps, services, datastores) make up the system, and how do they talk?" | Drawio | C4 palette + container shapes (service / datastore / queue). Zoom level: inside the system. |
| **Trust-zone sequence** | "How does a request traverse the security boundaries, with timing?" | Mermaid `sequenceDiagram` | Trust-zone notation in participant labels per [`../.agents/skills/mermaid-diagram/references/architecture-vocab.md`](../.agents/skills/mermaid-diagram/references/architecture-vocab.md) §Trust-zone notation. The signature security-first sequence view. |
| **C4 Dynamic** | "What is the message order for a specific scenario, in C4 vocabulary?" | Mermaid `C4Dynamic` | C4 actor stencils; relationship labels cite ADRs by ID; **no zone notation in the visual** — see anti-mixing rule. |
| **Decision tree / state machine** | "What state transitions are possible? What decisions branch where?" | Mermaid `flowchart` / `stateDiagram-v2` | Standard flowchart vocabulary; no zone colours needed. |

When a system has all four C4 levels documented, the convention is one diagram per level under the repo's diagrams directory — `docs/diagrams/` in a consuming repo, `architecture/diagrams/` in the architecture repo (per §File location convention). Filename pattern: `c4-l1-system-context.drawio`, `c4-l2-containers.drawio`, etc.

Cross-references: [`https://c4model.com/`](https://c4model.com/) for the full C4 methodology; [`https://www.drawio.com/blog/c4-modelling`](https://www.drawio.com/blog/c4-modelling) for the drawio C4 stencil library.

## File location convention

| In an architecture-repo style repo | In a consuming repo |
|---|---|
| `architecture/diagrams/<name>.drawio` + `<name>.svg` | `docs/diagrams/<name>.drawio` + `<name>.svg` |
| `architecture/diagrams/INDEX.md` lists every diagram with its source-of-truth doc reference | `docs/diagrams/INDEX.md` does the same |

**Naming:** lowercase-hyphenated, scope-prefixed. Examples:

- `eight-layer-control-model.drawio` (canonical reference; lives in the architecture repo)
- `self-hosted-vps-deployment-topology.drawio` (profile-specific)
- `agent-as-client-routing.drawio` (rule-specific)
- `consumer-l1-l2-passthrough.drawio` (consumer step or milestone)
- `dev-002-shared-secret-deviation.drawio` (consumer deviation diagram, ID-prefixed)
- `c4-l1-system-context.drawio` (C4 Level 1, archetype-prefixed)
- `c4-l2-containers.drawio` (C4 Level 2)

## Visual vocabulary

### Trust zones (Z0 → Z4)

Trust zones colour the **background** of areas the request crosses. The colour is fixed; consumers do not pick their own.

| Zone | Meaning | Background fill | Stroke (border) |
|---|---|---|---|
| `Z0` | Untrusted internet | `#fde2e2` (light red) | `#b85450` |
| `Z1` | Edge perimeter — TLS terminated, request routed | `#fff2cc` (light yellow) | `#d6b656` |
| `Z2` | Authenticated identity present (post-L3) | `#dae8fc` (light blue) | `#6c8ebf` |
| `Z3` | Authorized to proceed (post-L4 decision) | `#d5e8d4` (light green) | `#82b366` |
| `Z4` | Internal trust envelope (post-L6 issuance) | `#e1d5e7` (light purple) | `#9673a6` |

Zone label: top-left anchored inside the zone, 14pt, `#444444`.

### Layer ribbons (L1 → L8)

The eight control layers are rendered as **horizontal ribbons** crossing the diagram, with the layer name in a label on the left edge. Each layer has both a stroke colour AND a paired light fill — use the fill when the ribbon is itself the foreground (e.g., "future / placeholder" layers in a staged-rollout diagram); leave fill empty when services inside the ribbon already carry trust-zone fills.

| Layer | Stroke | Paired light fill | Common services in self-hosted-vps profile |
|---|---|---|---|
| `L1` Network reachability | `#9673a6` | `#ede8f0` | Cloudflare Tunnel, public DNS, firewall |
| `L2` Edge gateway / routing | `#6c8ebf` | `#e6edf5` | Kong (public), Traefik (internal) |
| `L3` Identity | `#82b366` | `#e8f0e3` | Keycloak, Kong `jwt` plugin |
| `L4` Authorization | `#d6b656` | `#f5eed7` | OpenFGA, Kong gateway-plugin authz check |
| `L5` Operational guardrails | `#b46504` | `#f0e4d3` | Kong rate-limiting, kill-switch flags |
| `L6` Orchestrator / BFF | `#a45fae` | `#efe4f1` | Consumer-owned BFF; issues the envelope |
| `L7` Service enforcement | `#d79b00` | `#f7ead2` | Per-service envelope verification |
| `L8` Semantic / agent reasoning | `#666666` (dashed) | `#e8e8e8` | Whichever AI coding agent and automation runtimes the consuming team uses — sit beside the stack, re-enter at L1/L2 as clients |

**Rendering rule for "future / placeholder" ribbons** (e.g., a diagram for step N that shows layers that step N+1 will populate): use the paired light fill, the per-layer stroke as a dashed border, and the per-layer stroke colour for the label text. This solves the "transparent ribbons on white background are unreadable" failure mode.

### Agent-as-client lane

A dashed grey lane (`#666666`, stroke-width 2, dashPattern `4 2`) entering the diagram from L8 and routing through L1→L2→… (the same path as a human user). Never a back-channel into L7. This lane visually enforces [ADR-0002](../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md).

### Deviation marker

A deviation from the reference architecture is shown as a **red dashed border** (`strokeColor=#c0392b`, `dashed=1`, `strokeWidth=2`) around the affected service or seam, with a numbered callout (`DEV-NNN`) matching the consumer's `security-first-adoption.md` `deviations:` list. The callout is a `#f8cecc` rounded rectangle with the deviation ID and a one-line summary; the full reason and compensating control stay in the adoption record, not on the diagram.

Example: trupryce's DEV-002 (shared-secret service-to-service trust instead of Z4 envelope) is rendered as a red dashed border around the L6↔L7 boundary in trupryce's deployment-topology diagram.

### Envelope crossing (Z3 → Z4)

The L6→L7 trust crossing (envelope issuance) is rendered as a **signed-arrow** glyph: a thick arrow with a small lock or seal icon on the arrow. This visually distinguishes envelope crossings from plain request flow. The architecture-repo skill ships the icon as a reusable drawio stencil.

### Connectors

| Connector type | Style | When |
|---|---|---|
| **Default request flow** | Orthogonal, 2px, `#333333` (dark gray), `endArrow=classic` | Synchronous request/response across layers |
| **Async** | Dashed (`dashPattern=8 4`), 2px, `#333333` | Async dispatch, queue publish, fire-and-forget |
| **Future / planned** | Dashed (`dashPattern=8 4`), 2px, `#c0392b` (red accent) | Connector that will be added in a later step; matches the deviation-marker palette so red consistently means "not in the current state" |
| **Step number badge** | Filled black circle, 18×18px, white text. See §Step-number badges below for full spec (size, anchor choice, legend-citation rule). | Staged rollouts; numbers match the brief's or proposal's step list |

Edge labels MUST set `labelBackgroundColor=#ffffff` so the text does not bleed into the line or underlying shapes. (Other background colours are allowed only when the label sits inside a coloured container where white would create a worse contrast; the default and overwhelmingly common case is white.)

### Step-number badges

For diagrams that depict a staged rollout (e.g., a consumer's L1→L5 onboarding arc), each connector or boundary that gets activated at a specific step carries a small numbered badge. The badge is:

- Shape: ellipse / circle
- Size: 18 × 18px
- Fill: `#000000`
- Text: `#ffffff`, 11pt, bold, centered
- Anchor: midpoint of the edge, or top-right corner of the activated container

When numbers refer to a specific external artifact (an OpenSpec proposal's step list, a runbook's numbered steps), cite that artifact in the legend (see below). The badge by itself is not enough — the reader needs to know which step list is being indexed.

### System boundary (owned vs external)

When a diagram crosses ownership boundaries (e.g., a consumer's services vs the architecture repo's reusable workflows; or a platform-edge service vs a per-team L6), mark the boundary explicitly:

| Ownership | Border style | Label position |
|---|---|---|
| **Owned by this repo / team** | Solid border, regular weight | Inside the boundary, top-left, `Owned: <team>` |
| **External (third party or different team)** | Dashed border, regular weight, `dashPattern=4 2` | Inside the boundary, top-left, `External: <provider>` or `Consumer-owned: <team>` |
| **Workspace-shared (e.g., the architecture repo's reusable workflows)** | Solid border, accent stroke (`#1168bd` blue), label `Workspace-shared` | Inside the boundary, top-left |

For C4 archetypes, ownership maps to C4's owned-vs-external palette (see [§C4 archetype palette](#c4-archetype-palette)).

### Iconography baseline

The standard prescribes shape vocabulary so a diagram is readable without legend memorisation:

| Element | Shape | Notes |
|---|---|---|
| Service / application | Rounded rectangle, radius `10` | Default for any active component |
| Datastore | Cylinder | Postgres, Redis, S3, sealed object stores |
| Queue / message bus | Stadium (pill / rounded-end rectangle) | SQS, RabbitMQ, internal queues |
| External system | Dashed-border rounded rectangle (see system boundary) | Cloud providers, third-party APIs, partner systems |
| Person / actor | C4 person stencil (drawio `mxgraph.c4.person`) or simple person icon | End users, operators, agent runtimes |
| Cloud / provider | Cloud shape (drawio default) | Network or provider abstractions |
| Boundary container | Rounded rectangle, transparent fill or paired light fill, descriptive label | Trust zones, ownership boundaries, layer ribbons |
| Step badge | Black filled circle | See §Step-number badges |

For profile-specific deployment diagrams (AWS, GCP, on-prem), the AWS / GCP / on-prem icon kits are optional — use them when they aid recognition, not when they distract. Reference: AWS architecture icons at <https://aws.amazon.com/architecture/icons/>; drawio AWS icon library at <https://github.com/m-radzikowski/diagrams-aws-icons>.

### C4 archetype palette

When producing a C4 System Context or Container diagram, use the C4-standard palette (which intentionally differs from our trust-zone palette so the two archetypes can never be confused in a single document):

| C4 element | Fill | Stroke | Text |
|---|---|---|---|
| Owned system / container | `#1168bd` (dark blue) | `#0e5da6` | `#ffffff` (white, bold) |
| External system | `#999999` (gray) | `#6b6b6b` | `#ffffff` (white) |
| Component (inside a container) | `#85bbf0` (light blue) | `#5d82a8` | `#222222` (near-black) |
| Person (external actor) | C4 person stencil; fill `#08427b` (dark navy), white text | — | — |
| Relationship label | Background `#ffffff` with thin border for readability | — | `#222222` |

If a C4 diagram needs trust-zone context (rare; usually a separate diagram), call out the trust zones in the diagram's prose caption, not in the visual.

### Text colour and contrast

| Text use | Colour | Notes |
|---|---|---|
| Primary text (headings, labels, body) | `#222222` (near-black) | Default for any text on light or white background |
| Secondary / metadata text | `#444444` (dark gray) on white; `#666666` on coloured fills | Subtitles, "Last reviewed" footers, "future layer" placeholders, italic annotations |
| Connector labels | `#222222` on `labelBackgroundColor=#ffffff` | Never let the label background be transparent — the line behind will degrade readability |
| White-on-dark text | `#ffffff` on C4 owned-system / external-system fills | Bold weight to compensate for the dark fill |

**Contrast floor (WCAG 2.1 AA):** body text MUST have a 4.5:1 contrast ratio against its background; large text (≥18pt, or ≥14pt bold) MUST have at least 3:1. Diagrams that fail this on the rendered `.svg` / `.png` will eventually be flagged by the (future) `validate-diagrams.sh` CI hook. Until then, treat it as a self-enforced quality bar.

**Common contrast failures to avoid:**

- Light italic gray (`#888888` or lighter) on white — fails AA for body text.
- Light layer-ribbon stroke (e.g., `#d6b656` gold) as the only colour for label text on a white background — fails AA.
- White text on the light trust-zone fills — fails AA badly. Light fills always get dark text.

### Title, legend, assumptions callout

Every diagram in `docs/diagrams/` or `architecture/diagrams/` MUST include:

- **Title.** Top-centre, 18pt bold, `#222222`. The headline question the diagram answers.
- **Subtitle.** Top-centre, 12pt regular, `#444444`. Profile / ref / dependency-record IDs, e.g., `self-hosted-vps profile · architecture_ref v0.1.1 · DEP-2026-05-24-001`.
- **Source-of-truth footer.** Bottom of the diagram, 10pt, `#444444`. See [§Source-of-truth linkage](#source-of-truth-linkage).

Every diagram that uses any non-default style (async / future connectors, step badges, deviation markers, ownership-boundary borders) MUST also include:

- **Legend block.** A small bordered box in the bottom-left or bottom-right, listing each non-default style used and what it means. Plain text + sample lines. Without this, a reader cannot interpret the diagram independently.

Diagrams that make load-bearing assumptions worth surfacing MAY include:

- **Assumptions callout.** A sticky-note shape (`shape=note`, fill `#fff2cc`, stroke `#d6b656`) labelled "Assumptions:", with one bullet per assumption. Italic content. Use sparingly — assumptions that should live in the prose belong in the prose, not on the diagram.

## Source-of-truth linkage

Every diagram **must** include a footer text element citing its source-of-truth doc:

```
Source: standards/repo-contract.md §<section> · architecture/profiles/<name>.md · ADR-NNNN
Last reviewed: YYYY-MM-DD by <handle>
```

This is the single most important convention. A diagram without a source-of-truth citation is a free-floating image that will drift; a diagram with one is an artifact a reviewer can validate against text.

## Drift mitigation

Diagrams drift faster than the docs they illustrate. Three mechanisms keep that under control:

1. **Source-of-truth citation in every diagram footer** (required, above). Reviewers comparing the diagram to its cited doc can spot drift in seconds.
2. **Quarterly review cadence in each `INDEX.md`.** `docs/diagrams/INDEX.md` (consuming repo) and `architecture/diagrams/INDEX.md` (architecture repo) carry a `last_reviewed:` and `next_review:` per entry. The skill's review mode validates these dates.
3. **CI optional `validate-diagrams.sh`** *(future; not in the first release)*. A pre-commit hook that flags any `.drawio` whose footer `Last reviewed:` is more than 90 days old when the diagram or its cited doc changes — plus contrast-floor checks against the rendered `.svg`. Tracked as a follow-up.

When you change a contract or standard that has a diagram citing it, **either update the diagram in the same PR or open an issue against the consumer that owns it**. The architecture repo's CODEOWNERS will block the merge of a contract change that has unresolved diagram-drift on cited diagrams.

## What this standard does NOT mandate

- Specific drawio version, theme, or visual styling beyond the vocabulary above.
- Whether to ship rendered diagrams in PR descriptions (recommended but optional).
- Whether to inline diagrams into ADRs (recommended for high-impact ADRs).
- Use of any specific drawing tool beyond drawio + mermaid; teams that prefer Excalidraw or Lucidchart may use them locally, but the canonical archive in `docs/diagrams/` or `architecture/diagrams/` must be in one of the standardised formats.
- Use of any specific style-import mechanism. A workspace style library ships at [`../architecture/diagrams/styles/workspace.drawio`](../architecture/diagrams/styles/workspace.drawio) as a **swatch-and-copy** library (open the file, copy the swatch you want, paste into your working diagram — see [`../architecture/diagrams/styles/README.md`](../architecture/diagrams/styles/README.md) for the workflow). Consumers SHOULD use it to inherit workspace-correct styles without typing hex codes by hand, but the vocabulary above remains the source of truth and diagrams MAY set their own styles directly. A formal `<mxlibrary>` drag-and-drop shape library is a future enhancement tracked alongside `validate-diagrams.sh`.

## Grandfathering and migration

Diagrams that predate this standard's Phase A+B additions (contrast floor, paired light fills, mandatory legend, archetype labels) are **grandfathered** — they remain valid as-is. New diagrams created after this standard lands MUST follow the full standard. Consumers polishing existing diagrams should adopt the new conventions at the next routine update; nothing in the architecture repo's CI will fail an existing diagram for missing these.

## Anti-patterns

- **Diagrams as the only place a fact lives.** The doc is authoritative; the diagram illustrates. If a diagram shows something not in the cited doc, fix the doc.
- **Re-colouring trust zones to match a team's brand.** The zone colours are workspace-wide vocabulary. Don't.
- **Showing agents on a back-channel into L7.** ADR-0002 says agents are clients. A diagram that shows otherwise is wrong; treat it as a finding, not a stylistic choice.
- **Profile-specific reference diagrams from the architecture repo.** The architecture repo ships ONE canonical reference (the eight-layer model) and a small number of profile-illustrative diagrams marked clearly as such; consumers draw their own deployment, not the architecture repo's "correct" one.
- **Mixing archetypes in one diagram.** A trust-zone overlay on a C4 Container diagram makes both archetypes harder to read. Pick one archetype per diagram; cross-link if both are needed.
- **Light italic gray on white background.** Fails the contrast floor. If a piece of text is "secondary" enough to want gray, either put it on a coloured fill (where `#666666` is fine) or commit to `#444444` minimum on white.
- **Legend by inference.** A diagram with multiple line styles, step badges, or ownership boundaries that lacks a legend forces every reader to reverse-engineer the conventions. Treat the legend as part of the diagram, not optional decoration.
- **Step numbers without their referenced list.** A `①` badge that doesn't name what step list it's indexing is noise. The legend should cite the OpenSpec proposal, runbook, or other artifact whose step numbers the badges follow.
