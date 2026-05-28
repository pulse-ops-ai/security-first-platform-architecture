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
- [x] No dependency records (additive change; no consumer is forced; opt-in adoption via grandfathering — see proposal §Affected consumers).

## Per-consumer integration tasks

**n/a** — no consumer is required to integrate.

Existing diagrams are explicitly grandfathered (proposal §Affected consumers; standard §Grandfathering and migration). `trupryce` ships no diagrams today; `platform-edge`'s step-1 diagram remains valid as-is and the team may polish it against the new conventions whenever convenient (typically bundled into its next routine PR). No consumer-side tasks block this PR.

## Post-merge

The original sequencing in this proposal's first revision was *"merge Phase A+B → tag v0.2.0 → Phase C"*. We have since revised to tag **after** Phase C lands. Two reasons:

1. **Phase C is the dog-food validation.** Phase C.3 produces the first reference diagrams *using the drawio skill against the Phase-A+B standard*. If that exercise surfaces issues in the standard (a poorly-rendering palette entry, an under-specified convention), we want to fix them in the standard **before** consumers pin to it, not after. Tagging between Phase A+B and Phase C locks in any standards bugs we haven't yet discovered.
2. **`v0.2.0` should feel complete.** Enterprises evaluate documentation kits by what's usable today, not what's promised next. A `v0.2.0` that ships standard + global-style file + at least one validated reference diagram is a coherent release; one that ships the standard alone reads as "spec for tools that don't exist yet."

Revised sequencing:

- [ ] **Phase C.1 + C.3** — the validation-and-tooling pair. Ship together as one PR (or two coordinated PRs landing back-to-back):
  - **C.1** — `architecture/diagrams/styles/workspace.drawio` global-style XML. Sets the workspace palette (zone fills + paired strokes, layer-ribbon strokes + paired fills, text colours, default edge style, step-badge style) so consumers import once via *Extras → Edit Diagram Style* and inherit it across every diagram. This is the largest enterprise-grade tooling win.
  - **C.3** — first reference diagram produced *using the drawio skill against the Phase-A+B standard, importing the C.1 global-style file*. Minimum: `architecture/diagrams/eight-layer-control-model.drawio` (the canonical reference every consumer benefits from). Ships paired `.svg`. Dog-foods both the skill and the standard.
  - If Phase C.3 surfaces Phase-A+B standard fixes, fold them into this PR (or a small predecessor PR) rather than letting v0.2.0 ship a known-flawed spec.
- [ ] **Cut `v0.2.0` tag** at main HEAD once Phase C.1 + C.3 have merged. Release notes cite Phase A+B + Phase C.1 + C.3 as the bundled surface. The `DEP-2026-05-24-001` platform-edge dependency record currently targets `v0.1.1` and may stay there if `platform-edge` does not need the new conventions in its next PR; or it can be bumped to `v0.2.0` when convenient (low-stakes either way).
- [ ] Archive this proposal: move `openspec/proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` to `openspec/archive/`; update frontmatter (`status: accepted`, `accepted_date`, `archived_date`, `merged_pr: <N>`). Per the `PR-N+1 archives PR-N` convention; combine with the `v0.2.0` housekeeping PR.
- [ ] **Phase C.2 / D / E (post-`v0.2.0`)** — polish that doesn't gate the tag:
  - **C.2** — full set of starter `.drawio` templates per archetype (trust-zone, deployment-topology, C4 System Context, C4 Container, C4 Dynamic). Each ships with placeholder content using the correct vocabulary; consumers `cp` and fill in. Could ship as `v0.2.1` or fold into `v0.3.0`.
  - **C.3 expansion** — add `self-hosted-vps-deployment-topology.drawio` and other profile-illustrative diagrams marked clearly as illustrative; consumers still draw their own.
  - **D** — `scripts/validate-diagrams.sh` + pre-commit hook flagging stale `Last reviewed:` footers (>90 days when the diagram or its cited doc changes) AND contrast-floor checks against the rendered `.svg`. Closes the drift-mitigation loop sketched in standard §Drift mitigation.
  - **E** — extend `templates/consuming-repo/` with a stub `docs/diagrams/` directory + starter `INDEX.md` referencing the new conventions.

## Notes

- The original (PR #19) diagramming-conventions standard called out "Profile-specific reference diagrams from the architecture repo" as an anti-pattern, and that anti-pattern stays. Phase C's reference diagrams are *limited examples* (eight-layer canonical + at most one profile-illustrative) marked clearly as such; consumers still draw their own deployments rather than the architecture repo's "correct" one.
- The contrast floor is a self-enforced quality bar in `v0.2.0`. The CI check (`validate-diagrams.sh` with contrast detection) is deliberately deferred to Phase D — it requires either a headless SVG-rendering check or a metadata-only proxy in the `.drawio` XML; both have implementation gotchas worth getting right separately.
- The C4 archetype additions in this PR are intentionally light-touch — vocabulary + palette + Mermaid syntax. C4 *templates* land in Phase C.2.
- "Phase C / D / E" labels in this proposal are illustrative; each will be a separate OpenSpec proposal when the work is staged. Splitting is a sequencing question for those future PRs, not this one.
