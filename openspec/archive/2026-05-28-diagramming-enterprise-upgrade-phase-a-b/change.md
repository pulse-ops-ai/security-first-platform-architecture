# OpenSpec Change: Enterprise-grade diagramming upgrade — Phase A + B

Companion to [`proposal.md`](proposal.md).

## Files modified

### `standards/diagramming-conventions.md`

Major expansion of the existing standard. Structure of the change:

| Section | State |
|---|---|
| Intro | Lightly reworded (mentions sequence + system-context archetypes alongside trust-zone work) |
| §Format choice | Lightly extended (C4 Container / System Context added to drawio row; C4 Dynamic added to Mermaid row) |
| **§Diagram archetypes** | **NEW** — seven-row table (trust-zone / layer architecture; deployment topology; C4 System Context; C4 Container; trust-zone sequence; C4 Dynamic; decision tree / state machine); rules on file naming for C4 levels; cross-references to c4model.com and drawio C4 blog |
| §File location convention | Lightly extended (new C4 examples: `c4-l1-system-context.drawio`, `c4-l2-containers.drawio`) |
| §Trust zones | Added a "Stroke (border)" column to the zone table (was previously only fill); label colour changed from `#666666` to `#444444` to align with the new contrast rule |
| §Layer ribbons | Added "Paired light fill" column; new rendering rule for "future / placeholder" ribbons (use paired fill, dashed stroke, layer-coloured label) — directly addresses the contrast-on-white failure mode from platform-edge's step-1 diagram |
| §Agent-as-client lane | Unchanged |
| §Deviation marker | Unchanged |
| §Envelope crossing | Unchanged |
| **§Connectors** | **NEW** — default request flow (orthogonal 2px `#333333`), async (dashed), future/planned (red dashed accent), step badges, mandatory `labelBackgroundColor` on edge labels |
| **§Step-number badges** | **NEW** — full spec (shape, size, fill, text, anchor); rule that the legend must cite the referenced step list |
| **§System boundary** | **NEW** — solid / dashed / accent borders for owned / external / workspace-shared; label position |
| **§Iconography baseline** | **NEW** — shape vocabulary table (service / datastore / queue / external / person / cloud / boundary / step-badge); links to AWS icon library |
| **§C4 archetype palette** | **NEW** — owned / external / container / component / person colours, intentionally distinct from trust-zone palette |
| **§Text colour and contrast** | **NEW** — primary `#222222`, secondary `#444444` on white / `#666666` on coloured fills; WCAG-AA contrast floor (4.5:1 body / 3:1 large); common contrast failures section |
| **§Title, legend, assumptions callout** | **NEW** — title (18pt bold), subtitle (12pt `#444444`), mandatory legend when non-default styles used, optional assumptions callout (sticky-note shape) |
| §Source-of-truth linkage | Unchanged |
| §Drift mitigation | Lightly extended (contrast-floor checks added to the future `validate-diagrams.sh` description) |
| §What this standard does NOT mandate | Added a paragraph deferring the drawio global-style XML file to Phase C |
| **§Grandfathering and migration** | **NEW** — existing diagrams predating Phase A+B are grandfathered as-is; new diagrams must follow the full standard |
| §Anti-patterns | Added 4 new anti-patterns: mixing archetypes in one diagram; light italic gray on white; legend by inference; step numbers without their referenced list |

### `.agents/skills/mermaid-diagram/references/architecture-vocab.md`

Added a `§C4 archetypes in Mermaid (C4Context, C4Container, C4Dynamic)` section with three full working examples using `platform-edge` as the realistic content:

- **C4 System Context (Level 1)** — `C4Context` showing platform-edge as a black box plus its external actors (end user, agent runtime, consumer L6, Keycloak).
- **C4 Container (Level 2)** — `C4Container` showing inside platform-edge (Kong, Traefik, Keycloak, OpenFGA, Redis) plus the external consumer-owned L6.
- **C4 Dynamic** — sequence-style C4 diagram for the "user request reaches consumer L7" scenario.

Plus a "C4 vs the trust-zone archetype" sub-section that codifies the anti-mixing rule and cross-references the standard. References at the end: c4model.com, c4model.com/diagrams/container, mermaid.js.org/syntax/c4.html.

## Files NOT modified

- `.agents/skills/drawio/SKILL.md` — already references the standard correctly via the workspace-aware paragraph in the body. Phase B's archetype additions are captured by the standard itself; the skill does not need to enumerate them.
- `.agents/skills/mermaid-diagram/SKILL.md` — same.
- `.claude/commands/{drawio,mermaid-diagram}.md` — same; route to canonical skills.
- `.claude/skills/`, `.codex/skills/` — auto-synced; no canonical changes that require shim regeneration.
- `templates/consuming-repo/` — no template changes in Phase A+B; templates remain valid.
- `architecture/diagrams/` — does not yet exist; first content will be Phase C dog-food templates.
- `infra/`, `architecture/profiles/` — unaffected.

## Contract changes

**No contract surface changes.** Strictly additive expansion of the diagramming-conventions standard:

- No existing diagram becomes non-conformant (grandfathering clause).
- No existing skill / template / contract is broken.
- No layer responsibility shift, no security-boundary change.
- No CI gate added in this PR; `validate-diagrams.sh` is referenced as a future addition only.

The standard's Phase-A+B additions are MUSTs **for new diagrams created after this lands** — but the grandfathering clause makes the migration soft.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. Consumers adopt at their next routine `architecture_ref` bump.

The `v0.2.0` tag is **not** cut at this PR's merge. Per the revised sequencing in [`tasks.md`](tasks.md) §Post-merge and [`proposal.md`](proposal.md) §Migration plan, the tag is cut **after Phase C.1 (drawio global-style XML) and Phase C.3 (first dog-fooded reference diagram) land**, so `v0.2.0` ships as a coherent spec + tooling + working example rather than a spec for tools that don't exist yet. Until then, consumers wanting the upgraded standard pin to `main`'s SHA (discouraged for production per the cross-repo-governance pinning rules) or wait for `v0.2.0`.

## Rollback

Each piece is independently reversible:

- Revert the standard's Phase A additions (paired fills, connectors, text/contrast, step badges) → consumer diagrams still readable; the original v0.1.1 conventions stay valid.
- Revert the standard's Phase B additions (archetypes, C4 palette, system boundary, iconography, title/legend rules) → drawio + Mermaid skills still ship the v0.1.1 vocabulary; consumers can produce trust-zone diagrams as before.
- Revert the mermaid-diagram architecture-vocab C4 section → Mermaid skill still works for sequence / flowchart / state.

No rollback is irreversible.

## Verification

- `bash scripts/validate-skills.sh`: PASS (no canonical SKILL.md content changes).
- `bash scripts/sync-agent-skills.sh --check`: PASS (no shim regeneration needed; reference file additions don't affect the validator).
- `bash scripts/validate-doc-indexes.sh`: PASS (no INDEX changes needed; the standard is already indexed from `standards/INDEX.md`).
- `bash scripts/validate-architecture.sh`: PASS (no new vendor-name leakage introduced; the C4 palette references generic "owned" / "external" not specific vendors).
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 19/19 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present (`standards/*` triggers Tier 2; matches intent).
- **Visual validation (manual, optional):** the standard's contrast-floor rule can be spot-checked against the platform-edge step-1 diagram — its italic gray annotations on white background fail the AA floor and would be flagged once `validate-diagrams.sh` exists. The grandfathering clause makes this informative, not blocking.
