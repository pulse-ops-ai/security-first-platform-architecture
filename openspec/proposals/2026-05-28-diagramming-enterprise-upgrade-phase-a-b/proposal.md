---
tier: 2
status: in_review
completion_state: architecture-complete
opened: 2026-05-28
target_decision_date: 2026-06-04
authors:
  - "@mike"
---

# OpenSpec Proposal: Enterprise-grade diagramming upgrade — Phase A + B

## Problem

The first consumer diagram produced against the v0.1.1 diagramming-conventions standard — `platform-edge`'s `step-1: L1+L2 pass-through topology` — surfaced four real gaps in that standard:

1. **Contrast failures on white backgrounds.** "Future / placeholder" layer ribbons rendered as dashed strokes (e.g., L4 gold `#d6b656`) on transparent fills are nearly unreadable. Italic light gray (`#666666`) annotations on white background fail WCAG-AA contrast. The standard prescribed stroke colours without prescribing paired light fills, text-colour rules, or a contrast floor — so a *conformant* diagram can end up technically-correct-but-hard-to-read.
2. **Connector conventions are missing.** Async vs synchronous, "future / planned" vs current-state, and staged-rollout step-number badges all had to be improvised by the platform-edge agent. Without a shared vocabulary, two consumers will draw the same scenario with different line styles.
3. **No archetype guidance.** The standard described one diagram type (trust-zone + layer ribbons). Enterprise documentation typically needs four–six diagram archetypes covering different questions (system context, container, sequence, deployment topology, decision tree). Without archetype names, consumers either overload one diagram with multiple lenses (the most common readability failure) or invent their own taxonomy.
4. **No C4 vocabulary.** C4 ([c4model.com](https://c4model.com/)) is the de-facto enterprise architecture documentation methodology and is natively supported by both drawio and Mermaid. The architecture repo's diagramming standard is opinionated toward security-trust-zone diagrams; C4 is opinionated toward containers/systems. They answer different questions about the same architecture — adopting C4 as a complementary archetype gives consumers a complete documentation kit rather than "the one diagram we ship."

Independently, basic enterprise-grade hygiene was missing from the standard: mandatory legend when non-default styles are used, system-boundary (owned vs external) convention, iconography baseline (cylinder for datastores, etc.), and title/subtitle convention.

The platform-edge diagram is the dog-food validation that the foundation works at all — the visual vocabulary applied correctly, the source-of-truth footer is present, the dependency-record citation links the diagram to its governance artifact. What we are doing in this PR is **upgrading the foundation to enterprise-grade** so the next consumer (and the next polish pass on platform-edge's existing diagram) gets a noticeably better visual product without the agent having to invent conventions on the fly.

## Proposed change

One coordinated update to `standards/diagramming-conventions.md` and one extension to the `mermaid-diagram` skill's `architecture-vocab.md` reference. Two phases bundled (per the user's earlier choice of A+B as one PR, C deferred).

### Phase A — visual polish + connectors

Additions to `standards/diagramming-conventions.md`:

- **Paired light-fill table per layer.** Every L1–L8 stroke colour gets a paired very-light fill (e.g., L3 stroke `#82b366` ↔ paired fill `#e8f0e3`). "Future / placeholder" ribbons MUST use the paired fill so the border + label are visible.
- **Text-colour rule.** Primary text `#222222`; secondary text `#444444` on white / `#666666` on coloured fills; never the lighter `#888888+` shades on white.
- **WCAG-AA contrast floor.** Body text ≥ 4.5:1; large text (≥18pt, or ≥14pt bold) ≥ 3:1. Self-enforced quality bar until a future `validate-diagrams.sh` CI hook enforces it automatically.
- **Connector conventions.** Default request flow (orthogonal 2px `#333333`), async (dashed `dashPattern=8 4`), future/planned (dashed + `#c0392b` red accent — matches deviation-marker palette), edge labels MUST set `labelBackgroundColor=#ffffff`.
- **Step-number badges.** Filled black circle, 18×18px, white 11pt bold text, anchored on the edge near the source endpoint. When numbers refer to an external step list (OpenSpec proposal, runbook), the legend MUST cite the source.

### Phase B — archetypes + iconography

Additions to `standards/diagramming-conventions.md`:

- **§Diagram archetypes table.** Six archetypes spelled out: (i) trust-zone / layer architecture; (ii) deployment topology; (iii) C4 System Context (Level 1); (iv) C4 Container (Level 2); (v) C4 Dynamic / sequence (Mermaid); (vi) decision tree / state machine (Mermaid). Each row: question it answers, format, vocabulary.
- **C4 archetype palette.** Owned system `#1168bd` (dark blue) with white bold text; external system `#999999` gray; container `#85bbf0` light blue; person `#08427b` navy stencil. Intentionally distinct from the trust-zone palette so the two archetypes can never be confused in a single document.
- **System-boundary convention.** Solid border for "owned by this repo / team"; dashed for "external"; accent stroke `#1168bd` for "workspace-shared" (e.g., the architecture repo's reusable workflows). Label position: inside the boundary, top-left, `Owned: <team>` / `External: <provider>` / `Workspace-shared`.
- **Iconography baseline.** Service = rounded rectangle r=10; datastore = cylinder; queue = stadium; external system = dashed-border rectangle; person = C4 person stencil; cloud / provider = cloud shape; boundary container = rounded rectangle with paired light fill or transparent.
- **Title, subtitle, legend, assumptions callout.** Title 18pt bold; subtitle 12pt `#444444`; mandatory legend whenever any non-default style is used; optional assumptions callout (sticky-note shape) for load-bearing assumptions.

Additions to `.agents/skills/mermaid-diagram/references/architecture-vocab.md`:

- **C4 archetypes in Mermaid section.** Working examples of `C4Context`, `C4Container`, and `C4Dynamic` syntax using platform-edge as the realistic content. Cross-reference to <https://mermaid.js.org/syntax/c4.html> for full syntax. Explicit "C4 vs trust-zone" anti-mixing rule.

### Phase B but deferred — explanation in standard

The standard's "What this standard does NOT mandate" section adds:

> A drawio global-style file is **not yet shipped**; it is deferred to a Phase C follow-up that will publish `architecture/diagrams/styles/workspace.drawio` for consumers to import via *Extras → Edit Diagram Style*.

That is the largest enterprise-grade-tooling win (consumers set the palette once and inherit it across all diagrams), and it makes sense to land *after* the standard has settled into its Phase-A+B shape. Tracked as a Phase-C follow-up; not in scope here.

## Alternatives considered

- **Just fix the contrast issue; defer archetypes + C4.** Smaller PR; less risk. Rejected because the platform-edge diagram surfaced all four gaps at once; a contrast-only fix would leave consumers still inventing connector and archetype conventions, and the second consumer would surface the same gaps. Better to address the foundation in one cycle.
- **Replace the trust-zone archetype with C4 entirely.** Cleaner narrative. Rejected because the trust-zone view is the security-first signature view of the architecture and is what makes diagrams produced against this standard distinguishable from generic C4 outputs from any team. Keep both; codify the format-choice rule so consumers pick the right one per diagram.
- **Allow diagrams to mix archetypes (trust zones overlaid on C4 Container).** Maximal expressiveness. Rejected because the most common readability failure observed in real enterprise diagrams is exactly this — too many overlays in one image. Make "one archetype per diagram" the anti-pattern rule and cross-link diagrams that need multiple lenses.
- **Ship the drawio global-style file in this PR (full Phase C).** One mega-PR. Rejected because a global-style file should be built *after* the standard is final — building it now risks shipping a style file that drifts from the standard as we polish. Phase C will dog-food the Phase A+B output: produce the global-style file using the now-final standard, plus starter templates per archetype.

## Impact

- **Repos affected:** the architecture repo only in this PR. After the PR lands and a new tag is cut, consumers may adopt at next routine `architecture_ref` bump.
- **Layers / profiles affected:** none. This is documentation + skill polish; no contract surface changes.
- **Standards affected:** `standards/diagramming-conventions.md` substantially expanded (additive; Phase A+B). No other standard changes.
- **Skills affected:** `.agents/skills/mermaid-diagram/references/architecture-vocab.md` gains a §C4 archetypes in Mermaid section.
- **Cross-repo contracts:** none. The standard is the only contract surface; everything in this PR is additive to it. Existing diagrams are explicitly grandfathered (see §Grandfathering and migration in the standard).
- **Security-boundary impact:** none. Diagrams illustrate; they do not enforce.
- **Drawio global-style file:** deferred to Phase C — explicitly documented in the standard's "What this standard does NOT mandate."

## Affected consumers (Tier 2/3 only)

| Consumer repo | Affected artifact | Dependency record | Owner |
|---|---|---|---|
| trupryce | n/a — opt-in additive; no current diagram needs revision | not required | `@mikegtech` / `@trupryce-platform` |
| platform-edge | `docs/diagrams/step-1-l1-l2-passthrough.drawio` — current diagram is grandfathered; team may apply the new contrast / legend / archetype rules at the next routine update or in a separate polish PR | not required | `@mikegtech` |

No dependency records are opened. The change is purely additive (no consumer is driven to a new ref; no existing contract surface changes); the standard's grandfathering clause makes adoption explicitly opt-in at the consumer's pace. Per the Dependency-record linkage rule in `team-os/cross-repo-governance.md`, a record is required only when a Tier 2/3 change "has downstream impact" — opt-in additive surface does not qualify.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`.
- **`deprecation_window:`** `n/a` — additive change. Existing diagrams are grandfathered (§Grandfathering and migration); no consumer is forced to update.
- **Migration steps:**
  1. Merge this PR. Cut a new architecture-repo tag (`v0.2.0`) so consumers can pin to a ref that includes the upgraded standard + C4 Mermaid patterns.
  2. Phase C follow-up PR builds the drawio global-style file (`architecture/diagrams/styles/workspace.drawio`) and the starter templates per archetype. Dog-foods the now-final standard.
  3. `platform-edge` polishes its existing step-1 diagram at its convenience using the new conventions (likely bundles the polish into its step-2 PR rather than opening a dedicated polish PR).
  4. Future consumer diagrams adopt the full standard from day one.

## Completion criteria

`completion_state: architecture-complete`

- `standards/diagramming-conventions.md` updated with all Phase A + Phase B sections listed above.
- `.agents/skills/mermaid-diagram/references/architecture-vocab.md` updated with the C4 archetypes section.
- All 19 pre-commit hooks pass.
- `openspec-triage.sh` classifies this PR as Tier 2 with proposal present.
- No skill SKILL.md content changes — the standard does the heavy lifting; the skills already reference the standard correctly.
- No infrastructure-side or template-side changes — Phase C will produce those.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete file diffs.
- [`tasks.md`](tasks.md) — execution plan.
- No ADRs — visual vocabulary is a convention, not a foundational architectural trade-off.
- No dependency records — opt-in additive; consumers grandfathered.
- **platform-edge step-1 diagram** — the real-world artifact that surfaced these gaps; will be the first existing diagram polished against the new standard (consumer's discretion on when).
- **C4 model documentation** — [c4model.com](https://c4model.com/) (referenced from the standard's archetype table).
- **Mermaid C4 syntax** — [mermaid.js.org/syntax/c4.html](https://mermaid.js.org/syntax/c4.html) (referenced from the architecture-vocab skill reference).
- **Phase C** (planned, not in this PR) — drawio global-style XML at `architecture/diagrams/styles/workspace.drawio`, starter templates per archetype, workspace-specific icon library / stencils.
