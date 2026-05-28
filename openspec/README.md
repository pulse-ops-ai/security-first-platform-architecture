# openspec/

This directory holds **OpenSpec** proposals for governed changes in this repository. See [`../team-os/openspec-policy.md`](../team-os/openspec-policy.md) for the policy (when OpenSpec is required, the three tiers, and the completion-state model) and [`../standards/openspec-standard.md`](../standards/openspec-standard.md) for the file layout.

## Layout

```
openspec/
  README.md                   # this file
  proposals/
    YYYY-MM-DD-short-title/
      proposal.md             # tier, problem, proposed change, alternatives, impact, affected consumers
      change.md               # concrete file diffs and contract before/after
      tasks.md                # execution plan with completion_state
  archive/                    # completed proposals (architecture-complete + adoption-complete)
```

## Creating a new proposal

1. Pick a date and a short title. Create `proposals/YYYY-MM-DD-<short-title>/`.
2. Copy templates from `../templates/openspec/`:

   ```bash
   D="openspec/proposals/$(date -u +%Y-%m-%d)-<short-title>"
   mkdir -p "$D"
   cp templates/openspec/proposal-template.md "$D/proposal.md"
   cp templates/openspec/change-template.md   "$D/change.md"
   cp templates/openspec/tasks-template.md    "$D/tasks.md"
   ```

3. Fill in frontmatter (`tier:`, `completion_state:`, etc.) and prose.
4. For Tier 2/3 with consumer impact: open one dependency record per affected consumer in `../portfolio/dependencies/` and link it from the proposal.

## CI enforcement

The `openspec-triage` workflow runs on PRs that touch architecture, standards, templates, skills, CI, or `AGENTS.md`. It calls `scripts/openspec-triage.sh` to classify the diff and confirm a proposal directory is present for Tier 2/3 changes.

## Current proposals

- [`proposals/2026-05-28-v0.2.0-housekeeping/`](proposals/2026-05-28-v0.2.0-housekeeping/) — Tier 2, in_review: cuts the deferred `v0.2.0` tag (post-merge) and bundles four housekeeping fixes — (i) rewrite the `standards/diagramming-conventions.md` §What this standard does NOT mandate paragraph from the misleading "deferred Phase C / *Extras → Edit Diagram Style*" wording to a positive description of the swatch-and-copy library PR #23 actually shipped; (ii) update `.agents/skills/drawio/SKILL.md` to recommend `--embed-svg-fonts false` for committed SVG (drawio's default embeds fonts as base64 and produces SVGs that trip this repo's 500 KB pre-commit ceiling); (iii) archive PR #22's proposal; (iv) archive PR #23's proposal. Tag itself is cut after merge per `tasks.md` §Post-merge. Additive; no consumer is forced; dependency-record bumps are out of scope.

## Archived proposals

- [`archive/2026-05-16-enforcement-and-skill-rigor/`](archive/2026-05-16-enforcement-and-skill-rigor/) — Tier 2, accepted, architecture-complete (merged in PR #3)
- [`archive/2026-05-17-coverage-and-polish/`](archive/2026-05-17-coverage-and-polish/) — Tier 2, accepted, architecture-complete (merged in PR #8)
- [`archive/2026-05-17-audience-tiered-navigation/`](archive/2026-05-17-audience-tiered-navigation/) — Tier 2 by intent (script said Tier 3 due to path-based over-classification, documented), accepted, architecture-complete (merged in PR #11)
- [`archive/2026-05-17-repo-healthcheck-alignment/`](archive/2026-05-17-repo-healthcheck-alignment/) — Tier 2, accepted, architecture-complete (merged in PR #13)
- [`archive/2026-05-17-template-completeness-and-workflow-portability/`](archive/2026-05-17-template-completeness-and-workflow-portability/) — Tier 2 by intent (script said Tier 3 due to `standards/repo-contract.md` path; additive doc section), accepted, architecture-complete (merged in PR #14)
- [`archive/2026-05-28-reusable-workflow-event-name-hotfix/`](archive/2026-05-28-reusable-workflow-event-name-hotfix/) — Tier 2 by script-classification, **Tier-1 hotfix by intent**, accepted, architecture-complete (merged in PR #20). Reverts the always-false `github.event_name == 'workflow_call'` guard in the reusable workflows; unblocked `platform-edge`'s first consumer-mode CI. Tagged as `v0.1.1`.
- [`archive/2026-05-28-diagramming-conventions-and-skills/`](archive/2026-05-28-diagramming-conventions-and-skills/) — Tier 2, accepted, architecture-complete (merged in PR #19). Shipped `standards/diagramming-conventions.md` + canonical `drawio` + `mermaid-diagram` skills + vendor adapter shims + Claude slash commands. Bundled into `v0.1.1` alongside the hotfix.
- [`archive/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/`](archive/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/) — Tier 2, accepted, architecture-complete (merged in PR #22). Enterprise-grade upgrade to `standards/diagramming-conventions.md` covering visual polish + connectors (Phase A) and archetypes + iconography (Phase B), plus C4 archetypes in the Mermaid `architecture-vocab.md` reference. Held back from `v0.2.0` per its own `tasks.md` §Post-merge ("tag after Phase C lands") and tagged as part of `v0.2.0` alongside PR #23.
- [`archive/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/`](archive/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/) — Tier 2, accepted, architecture-complete (merged in PR #23). Shipped `architecture/diagrams/styles/workspace.drawio` swatch-and-copy style library + `styles/README.md` (C.1) and `architecture/diagrams/eight-layer-control-model.drawio` vendor-neutral canonical reference (C.3) — the tag-gating pair PR #22 had deferred. Documented a deliberate deviation from PR #22's description (swatch-and-copy, not *Extras → Edit Diagram Style*). Tagged as `v0.2.0`.
