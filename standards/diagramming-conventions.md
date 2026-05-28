# Diagramming conventions

A shared visual vocabulary for architecture, trust-zone, and deployment-topology diagrams produced by repos in this workspace. Without conventions, every consumer invents its own colors, shapes, and layer markings — cross-repo audits get harder, not easier.

The skills that produce diagrams against this vocabulary live in [`../.agents/skills/drawio/`](../.agents/skills/drawio/SKILL.md) and [`../.agents/skills/mermaid-diagram/`](../.agents/skills/mermaid-diagram/SKILL.md). This file is the **what** (vocabulary + conventions); those skills are the **how** (tool wiring + production).

## Format choice — when to use which

| Diagram type | Format | Why |
|---|---|---|
| Layered architecture, trust-zone overlays, deployment topology, dependency graphs | **Drawio** (`.drawio` + rendered `.svg` / `.png`) | Multi-layer spatial work needs proper boxes, lanes, and corridor routing. Drawio handles it; mermaid does not. |
| Request sequence, OAuth/OIDC flow, agent-as-client routing, incident timeline | **Mermaid** (`mermaidjs` fenced block in markdown) | Sequence diagrams render natively in GitHub markdown; no second source-of-truth file to keep in sync. |
| Whiteboard sketch, RFC ideation, workshop output | Either is fine; not yet standardised | Don't optimise prematurely — promote to drawio/mermaid only if the sketch becomes a recurring reference. |

`.drawio` files **must** be paired with a rendered `.svg` (preferred) or `.png` alongside, so readers without drawio can see the diagram in GitHub. The skill handles export.

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

## Visual vocabulary

### Trust zones (Z0 → Z4)

Trust zones colour the **background** of areas the request crosses. The colour is fixed; consumers do not pick their own.

| Zone | Meaning | Background colour (drawio fill) |
|---|---|---|
| `Z0` | Untrusted internet | `#fde2e2` (light red) |
| `Z1` | Edge perimeter — TLS terminated, request routed | `#fff2cc` (light yellow) |
| `Z2` | Authenticated identity present (post-L3) | `#dae8fc` (light blue) |
| `Z3` | Authorized to proceed (post-L4 decision) | `#d5e8d4` (light green) |
| `Z4` | Internal trust envelope (post-L6 issuance) | `#e1d5e7` (light purple) |

Stroke colour for the zone label: `#666666`, 14pt, top-left anchored inside the zone.

### Layer ribbons (L1 → L8)

The eight control layers are rendered as **horizontal ribbons** crossing the diagram, with the layer name in a label on the left edge. Use these stroke colours; fills inside the ribbon (the actual services) follow the trust-zone colour the ribbon sits within.

| Layer | Stroke colour | Common services in self-hosted-vps profile |
|---|---|---|
| `L1` Network reachability | `#9673a6` | Cloudflare Tunnel, public DNS, firewall |
| `L2` Edge gateway / routing | `#6c8ebf` | Kong (public), Traefik (internal) |
| `L3` Identity | `#82b366` | Keycloak, Kong `jwt` plugin |
| `L4` Authorization | `#d6b656` | OpenFGA, Kong gateway-plugin authz check |
| `L5` Operational guardrails | `#b46504` | Kong rate-limiting, kill-switch flags |
| `L6` Orchestrator / BFF | `#a45fae` | Consumer-owned BFF; issues the envelope |
| `L7` Service enforcement | `#d79b00` | Per-service envelope verification |
| `L8` Semantic / agent reasoning | `#666666` (dashed) | Whichever AI coding agent and automation runtimes the consuming team uses — sit beside the stack, re-enter at L1/L2 as clients |

### Agent-as-client lane

A dashed grey lane (`#666666`, stroke-width 2, dashPattern `4 2`) entering the diagram from L8 and routing through L1→L2→… (the same path as a human user). Never a back-channel into L7. This lane visually enforces [ADR-0002](../docs/decisions/ADR-0002-agents-are-clients-not-insiders.md).

### Deviation marker

A deviation from the reference architecture is shown as a **red dashed border** (`strokeColor=#c0392b`, `dashed=1`, `strokeWidth=2`) around the affected service or seam, with a numbered callout (`DEV-NNN`) matching the consumer's `security-first-adoption.md` `deviations:` list. The callout is a `#f8cecc` rounded rectangle with the deviation ID and a one-line summary; the full reason and compensating control stay in the adoption record, not on the diagram.

Example: trupryce's DEV-002 (shared-secret service-to-service trust instead of Z4 envelope) is rendered as a red dashed border around the L6↔L7 boundary in trupryce's deployment-topology diagram.

### Envelope crossing (Z3 → Z4)

The L6→L7 trust crossing (envelope issuance) is rendered as a **signed-arrow** glyph: a thick arrow with a small lock or seal icon on the arrow. This visually distinguishes envelope crossings from plain request flow. The architecture-repo skill ships the icon as a reusable drawio stencil.

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
3. **CI optional `validate-diagrams.sh`** *(future; not in the first release)*. A pre-commit hook that flags any `.drawio` whose footer `Last reviewed:` is more than 90 days old when the diagram or its cited doc changes. Tracked as a follow-up.

When you change a contract or standard that has a diagram citing it, **either update the diagram in the same PR or open an issue against the consumer that owns it**. The architecture repo's CODEOWNERS will block the merge of a contract change that has unresolved diagram-drift on cited diagrams.

## What this standard does NOT mandate

- Specific drawio version, theme, or visual styling beyond the vocabulary above.
- Whether to ship rendered diagrams in PR descriptions (recommended but optional).
- Whether to inline diagrams into ADRs (recommended for high-impact ADRs).
- Use of any specific drawing tool beyond drawio + mermaid; teams that prefer Excalidraw or Lucidchart may use them locally, but the canonical archive in `docs/diagrams/` or `architecture/diagrams/` must be in one of the standardised formats.

## Anti-patterns

- **Diagrams as the only place a fact lives.** The doc is authoritative; the diagram illustrates. If a diagram shows something not in the cited doc, fix the doc.
- **Re-colouring trust zones to match a team's brand.** The zone colours are workspace-wide vocabulary. Don't.
- **Showing agents on a back-channel into L7.** ADR-0002 says agents are clients. A diagram that shows otherwise is wrong; treat it as a finding, not a stylistic choice.
- **Profile-specific reference diagrams from the architecture repo.** The architecture repo ships ONE canonical reference (the eight-layer model) and a small number of profile-illustrative diagrams marked clearly as such; consumers draw their own deployment, not the architecture repo's "correct" one.
