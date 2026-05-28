---
completion_state: architecture-complete
---

# OpenSpec Tasks: Enterprise-grade diagramming upgrade — Phase A + B

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | Add paired light-fill column to the §Layer ribbons table (per-layer; addresses contrast-on-white failure mode) | @mike | completed | this PR |
| 2 | Add new §Connectors section (default / async / future / step badges) | @mike | completed | this PR |
| 3 | Add new §Step-number badges section with full spec | @mike | completed | this PR |
| 4 | Add new §System boundary section (owned / external / workspace-shared border conventions) | @mike | completed | this PR |
| 5 | Add new §Iconography baseline section (shape vocabulary table) | @mike | completed | this PR |
| 6 | Add new §C4 archetype palette section (intentionally distinct from trust-zone palette) | @mike | completed | this PR |
| 7 | Add new §Text colour and contrast section (primary / secondary text rules; WCAG-AA floor) | @mike | completed | this PR |
| 8 | Add new §Title, legend, assumptions callout section (mandatory legend when non-default styles used) | @mike | completed | this PR |
| 9 | Add new §Diagram archetypes section (six-row table; trust-zone / topology / C4 levels / Mermaid variants) | @mike | completed | this PR |
| 10 | Add new §Grandfathering and migration section (existing diagrams remain valid) | @mike | completed | this PR |
| 11 | Extend §Format choice and §File location convention with C4 archetype mentions | @mike | completed | this PR |
| 12 | Extend §Trust zones with explicit stroke colours (was previously fill only) and update label colour to `#444444` per the new contrast rule | @mike | completed | this PR |
| 13 | Add 4 new anti-patterns (mix archetypes / light italic gray on white / legend by inference / step numbers without referenced list) | @mike | completed | this PR |
| 14 | Update §What this standard does NOT mandate to defer the drawio global-style XML to Phase C | @mike | completed | this PR |
| 15 | Add §C4 archetypes in Mermaid section to `.agents/skills/mermaid-diagram/references/architecture-vocab.md` with C4Context / C4Container / C4Dynamic working examples + anti-mixing rule | @mike | completed | this PR |
| 16 | Add reference URLs (c4model.com, drawio C4 blog, Mermaid C4 syntax, AWS icons) at the right insertion points | @mike | completed | this PR |
| 17 | Confirm `pre-commit run --all-files`: 19/19 PASS | @mike | completed | this PR |
| 18 | Confirm `openspec-triage.sh`: Tier 2 with proposal present | @mike | completed | this PR |
| 19 | Open PR | @mike | completed | this PR |

## Definition of done

### Pre-merge (this PR must satisfy before merge)

- [x] Standard expanded with all Phase A sections (paired fills, connectors, step badges, text & contrast).
- [x] Standard expanded with all Phase B sections (archetypes, C4 palette, system boundary, iconography, title / legend / assumptions).
- [x] Standard's grandfathering clause is explicit so existing diagrams are not invalidated.
- [x] Mermaid `architecture-vocab.md` reference extended with C4 patterns and the C4-vs-trust-zone anti-mixing rule.
- [x] `bash scripts/validate-skills.sh`: PASS.
- [x] `bash scripts/sync-agent-skills.sh --check`: PASS (zero errors).
- [x] `bash scripts/validate-architecture.sh`: PASS (no vendor-name leakage).
- [x] `bash scripts/repo-healthcheck.sh`: PASS.
- [x] `pre-commit run --all-files`: 19/19 PASS.
- [x] `openspec-triage.sh`: Tier 2 with proposal present.
- [x] No ADR required (visual vocabulary is a convention, not a foundational architectural trade-off).
- [x] No dependency records (additive change; no consumer is forced; opt-in adoption via grandfathering).

### Post-merge (happens after this PR lands)

- [ ] Cut a new architecture-repo tag `v0.2.0` reflecting the upgraded contract surface. The `DEP-2026-05-24-001` platform-edge dependency record currently targets `v0.1.1` and may stay there if `platform-edge` does not need the new conventions in its next PR; or it can be bumped to `v0.2.0` when convenient (low-stakes either way).
- [ ] Archive this proposal: move `openspec/proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` to `openspec/archive/`; update frontmatter (`status: accepted`, `accepted_date`, `archived_date`, `merged_pr: <N>`). Per the `PR-N+1 archives PR-N` convention; can be combined with the `v0.2.0` housekeeping PR.
- [ ] **Phase C PR(s)** — the big enterprise-grade tooling deliverables. Three sub-pieces, each shippable independently:
  - **C.1** — `architecture/diagrams/styles/workspace.drawio` global-style XML file. Sets the workspace palette (zone fills + paired strokes, layer-ribbon strokes + paired fills, text colours, default edge style, step-badge style) so consumers import once via *Extras → Edit Diagram Style* and inherit it across all diagrams.
  - **C.2** — `architecture/diagrams/templates/` starter `.drawio` per archetype (trust-zone, deployment-topology, C4 System Context, C4 Container). Each ships with placeholder content using the correct vocabulary; consumers `cp` and fill in.
  - **C.3** — `architecture/diagrams/` first-class reference diagrams produced *using the drawio skill against the Phase-A+B standard* — dog-food validation. Minimum set: `eight-layer-control-model.drawio` (canonical reference) + `self-hosted-vps-deployment-topology.drawio` (the profile both current consumers use). Ships paired `.svg` renderings.
- [ ] **Optional later** — `scripts/validate-diagrams.sh` + pre-commit hook flagging stale `Last reviewed:` footers (>90 days when the diagram or its cited doc changes) AND contrast-floor checks against the rendered `.svg`. Closes the drift-mitigation loop the standard sketches in §Drift mitigation.
- [ ] **Optional later** — extend `templates/consuming-repo/` with a stub `docs/diagrams/` directory + starter `INDEX.md` referencing the new conventions.

## Notes

- The original (PR #19) diagramming-conventions standard called out "Profile-specific reference diagrams from the architecture repo" as an anti-pattern, and that anti-pattern stays. Phase C's reference diagrams are *limited examples* (eight-layer + one profile) marked clearly as such; consumers still draw their own deployments rather than the architecture repo's "correct" one.
- The contrast floor is a self-enforced quality bar for now. Adding the CI check (`validate-diagrams.sh` with contrast detection) is in the Phase-C tasks but is deliberately a separate ship — it requires either a headless SVG-rendering check or a metadata-only proxy in the `.drawio` XML; both have implementation gotchas worth getting right separately.
- The C4 archetype additions are intentionally light-touch. We don't ship C4 *templates* in this PR (that's Phase C); we just codify the vocabulary, the palette, and the Mermaid syntax so the next consumer needing a C4 diagram has a shared shape to follow.
- "Phase C" in this proposal is illustrative; it will be one or more separate proposals when the work is staged. Splitting C.1 / C.2 / C.3 is a sequencing question for that future PR series, not this one.
