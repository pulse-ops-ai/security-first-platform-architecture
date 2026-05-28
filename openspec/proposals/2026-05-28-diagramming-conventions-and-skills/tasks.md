---
completion_state: architecture-complete
---

# OpenSpec Tasks: Diagramming conventions + drawio / mermaid skills

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | Author `standards/diagramming-conventions.md` (visual vocabulary, file-location convention, drift mitigation, anti-patterns) | @mike | completed | this PR |
| 2 | Author canonical `.agents/skills/drawio/SKILL.md` matching the validator's structural requirements (frontmatter `name` + `description`, body `## Procedure` + `## Output`) | @mike | completed | this PR |
| 3 | Author `.agents/skills/drawio/references/edge-routing.md` (load-on-demand routing cookbook) | @mike | completed | this PR |
| 4 | Author `.agents/skills/drawio/references/x86_64-install.md` (load-on-demand install / headless setup) | @mike | completed | this PR |
| 5 | Author canonical `.agents/skills/mermaid-diagram/SKILL.md` (companion for inline-in-markdown diagrams) | @mike | completed | this PR |
| 6 | Author `.agents/skills/mermaid-diagram/references/architecture-vocab.md` (Mermaid mapping of the conventions standard) | @mike | completed | this PR |
| 7 | Update `.agents/skills/INDEX.md` — new "Diagramming" section | @mike | completed | this PR |
| 8 | Update `standards/INDEX.md` — new `diagramming-conventions.md` entry | @mike | completed | this PR |
| 9 | Bootstrap Claude + Codex shims for both skills via `sync-agent-skills.sh --bootstrap` | @mike | completed | this PR |
| 10 | Author Claude slash commands `.claude/commands/{drawio,mermaid-diagram}.md` | @mike | completed | this PR |
| 11 | Run `sync-agent-skills.sh --check` and confirm zero errors for the new skills | @mike | completed | this PR |
| 12 | Run all 19 pre-commit hooks; confirm PASS | @mike | completed | this PR |
| 13 | Open the PR | @mike | completed | this PR |

## Definition of done

### Pre-merge (this PR must satisfy before merge)

- [x] New standard at `standards/diagramming-conventions.md` lands and is indexed.
- [x] Both new canonical skills present at `.agents/skills/drawio/` and `.agents/skills/mermaid-diagram/` with required `## Procedure` and `## Output` sections.
- [x] Reference files present at the documented paths (`references/edge-routing.md`, `references/x86_64-install.md`, `references/architecture-vocab.md`).
- [x] Vendor adapter shims generated for both skills (Claude + Codex).
- [x] Claude slash commands present for both skills.
- [x] `bash scripts/sync-agent-skills.sh --check`: PASS (0 errors). Pre-existing warnings on `pull-from-notion` and `push-to-notion` Codex shims are unchanged and unaffected.
- [x] `bash scripts/validate-skills.sh`: PASS.
- [x] `openspec-triage.sh` classifies this PR as Tier 2 with proposal present.
- [x] `pre-commit run --all-files`: 19/19 hooks PASS.
- [x] No ADR required (Tier 2; visual vocabulary is a convention, not a foundational architectural trade-off).
- [x] No dependency records (additive change; no consumer is forced; opt-in adoption).

### Post-merge (happens after this PR lands)

- [ ] Cut a new architecture-repo tag `v0.2.0` reflecting the additive contract surface. The dependency record for platform-edge (`DEP-2026-05-24-001`) currently targets `v0.1.0`; if platform-edge wants the new skills, that record can stay at `v0.1.0` (it predates this change) and a separate dependency record can be opened later when platform-edge bumps to `v0.2.0`.
- [ ] Archive this proposal: move `openspec/proposals/2026-05-28-diagramming-conventions-and-skills/` to `openspec/archive/`; update frontmatter (`status: accepted`, `accepted_date`, `archived_date`, `merged_pr: <N>`). Happens in the next architecture-repo PR per the `PR-N+1 archives PR-N` convention.
- [ ] Phase 2 PR: produce the canonical eight-layer-control-model diagram and the self-hosted-vps deployment-topology diagram under `architecture/diagrams/`, **using the newly-shipped drawio skill**. Ship paired `.drawio` source + rendered `.svg`. This dog-foods the foundation and validates that the skill produces "very professional" output as intended.
- [ ] Optional Phase 3 PR: extend the consumer template (`templates/consuming-repo/`) to include a stub `docs/diagrams/` directory with a starter `INDEX.md` so new consumers have the convention scaffolded by construction.
- [ ] Optional Phase 4 PR: `scripts/validate-diagrams.sh` + pre-commit hook flagging stale `Last reviewed:` footers (>90 days when the diagram or its cited doc changes). Useful drift-mitigation but not load-bearing for v1.

## Notes

- The user explicitly chose Option 3 (skill + standard + example diagrams) and wants the deliverable to look "very professional." The example diagrams are deferred from this PR to Phase 2 because authoring complex drawio XML by hand without being able to render it for visual validation would compromise that quality bar. Phase 2 will produce the examples *using the skill we are shipping*, which is both a dog-fooding validation and the surest path to professional output. Trade-off is explicit in the proposal's "Deliberately deferred" section.
- The drawio skill is largely the user-provided content from their preferred skill source, restructured to satisfy the canonical-skill validator (the `## Procedure` and `## Output` headers were renamed from `## How to create a diagram` and an implicit output, and `no-shim` markers were removed so Claude / Codex can auto-discover the skill via vendor adapters). All technical content — WSL2 / ARM64 / headless installation, edge-routing cookbook, XML format reference — is preserved verbatim where the source provided it.
- The mermaid-diagram skill is new content, written to be a true companion (not a competitor) to drawio. The format-choice rule in the standard prevents redundancy: spatial / layered work goes to drawio; time-ordered / decision-flow work goes to Mermaid.
