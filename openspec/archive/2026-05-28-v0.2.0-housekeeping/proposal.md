---
tier: 2
status: accepted
completion_state: architecture-complete
opened: 2026-05-28
target_decision_date: 2026-05-29
accepted_date: 2026-05-28
archived_date: 2026-05-29
merged_pr: 24
authors:
  - "@mike"
---

# OpenSpec Proposal: v0.2.0 housekeeping — cut tag, wording fix, skill fix, proposal archives

## Problem

After [PR #22](../../../pull/22) (Phase A+B — enterprise-grade diagramming-conventions standard) and [PR #23](../../../pull/23) (Phase C — workspace style library + canonical eight-layer reference diagram) merged on 2026-05-28, **`v0.2.0` is still untagged**. Per PR #22's `tasks.md` §Post-merge, the tag was deliberately held until Phase C landed so the release would ship "standard + working tool + worked example" rather than a spec for tools that don't exist yet. Phase C closed that gap. Consumer agents observing `main` past `v0.1.1` now see 10+ commits worth of v0.2.0-worthy surface area with no tag to pin against.

In the process of shipping PR #23 we also discovered two follow-up items that belong with the tag:

1. **The standard's "deferred to Phase C" paragraph drifted.** `standards/diagramming-conventions.md` §What this standard does NOT mandate describes the workspace style file as something consumers will "import via *Extras → Edit Diagram Style*". That mechanism does not actually do what the PR #22 author hoped — *Extras → Edit Diagram Style* sets the style JSON for newly-inserted-unstyled shapes in one diagram at a time, not an importable vocabulary of named, ready-to-use shapes. What PR #23 shipped instead is a **swatch-and-copy** library (open → copy swatch → paste → rename). The deviation rationale is documented in PR #23's proposal §Deviation, but the standard's wording still points at the original (wrong) mechanism, which will mislead the next consumer to consult it.
2. **The `drawio` skill silently produces SVGs that trip this repo's 500 KB pre-commit ceiling.** `.agents/skills/drawio/SKILL.md` recommends `-e --embed-diagram` for SVG export without `--embed-svg-fonts false`. drawio's SVG export defaults to embedding fonts as base64; the resulting files routinely come out >1 MB. PR #23's `eight-layer-control-model.drawio.svg` rendered at 2.0 MB with the skill's default flags — which would have failed the `check-added-large-files` hook on every fresh consumer agent — and dropped to 80 KB once `--embed-svg-fonts false` was passed. Editable XML stays embedded; the SVG renders in browsers using system-font fallbacks. A fresh consumer agent following the skill verbatim would have hit the same failure we did.

`v0.2.0` is the moment when consumers will look at the architecture repo's surface area and start pinning. Cutting the tag without these two fixes ships a known-misleading paragraph and a known-broken skill default into the first release that consumers will trust.

## Proposed change

One housekeeping PR that lands five small things together so `v0.2.0` is coherent:

### 1. Cut the `v0.2.0` tag

Tag `main` HEAD after this PR merges. Release notes cite PR #22 + PR #23 as the bundled surface; PR #20 (workflow event-name hotfix) and PR #21 (v0.1.1 housekeeping) are already shipped under `v0.1.1` and not re-listed.

### 2. Fix `standards/diagramming-conventions.md` §What this standard does NOT mandate wording

Replace the one paragraph that still describes the workspace style file as "deferred to a Phase C follow-up that will publish ... for consumers to import via *Extras → Edit Diagram Style*" with a paragraph that describes what actually ships:

- File lives at `architecture/diagrams/styles/workspace.drawio` with paired `.svg` and `README.md` (already linked from `architecture/diagrams/INDEX.md` per PR #23).
- Workflow is **swatch-and-copy** (open the file, copy the swatch you want, paste into your working diagram), not *Extras → Edit Diagram Style*.
- A formal `<mxlibrary>` drag-and-drop shape library is a future enhancement tracked alongside `validate-diagrams.sh`.
- Adoption is opt-in: consumers MAY type hex codes directly per the vocabulary tables above if they prefer; the vocabulary remains the source of truth.

### 3. Update `.agents/skills/drawio/SKILL.md` to recommend `--embed-svg-fonts false`

Three small additive edits in the canonical skill:

- **§Procedure step 4** — when exporting SVG into a committed `docs/diagrams/` or `architecture/diagrams/` directory, also pass `--embed-svg-fonts false` (with a one-line rationale: drawio's default embeds fonts as base64 and routinely produces files >1 MB that trip repo-level max-file-size pre-commit hooks).
- **§Supported export formats** — the SVG row gets a "pass `--embed-svg-fonts false` for committed SVG" note.
- **§Locating the CLI** flags list — new entry for `--embed-svg-fonts <true/false>` documenting the default and the recommendation.

The shims under `.claude/skills/drawio/` and `.codex/skills/drawio/` delegate to canonical and need no change; `scripts/sync-agent-skills.sh --check` confirms no drift.

### 4. Archive PR #22's proposal

`git mv openspec/proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b → openspec/archive/`. Update frontmatter: `status: accepted`, `accepted_date: 2026-05-28`, `archived_date: 2026-05-28`, `merged_pr: 22`. Per the workspace's "PR-N+1 archives PR-N" convention and PR #22's own `tasks.md` §Post-merge ("combine with the `v0.2.0` housekeeping PR").

### 5. Archive PR #23's proposal

Same treatment for `openspec/proposals/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram → openspec/archive/` with `merged_pr: 23`.

### Out of scope

- **Dependency-record bumps.** `DEP-2026-05-24-001` (platform-edge) currently targets `v0.1.1`. The change is low-stakes — `platform-edge` can stay on `v0.1.1` or bump to `v0.2.0` whenever convenient, and nothing in this PR forces a re-pin. Deferred to a separate `chore/dep-records-v0.2.0-pinning` if and when consumers actually want the bump.
- **Phase C.2 / D / E** — explicitly deferred in PR #23's proposal and in `architecture/diagrams/INDEX.md` §"Phase C scope and what comes next"; each ships as its own future OpenSpec proposal.
- **Generalising the SVG-font fix to other consumer repos.** Other repos (e.g., `platform-edge`) MAY adopt the `--embed-svg-fonts false` recommendation when they next polish a diagram, but nothing in this PR forces it; their existing diagrams are grandfathered (per PR #22's §Grandfathering and migration).

## Alternatives considered

- **Cut the tag, defer the wording + skill fixes to v0.2.1.** Smaller PR. Rejected because (a) the misleading paragraph will be the *first* place a consumer looks for the workspace style file's intended workflow — getting it right at the tag is much higher-leverage than fixing it later; (b) the skill default produces hook failures, and every fresh-agent consumer between now and v0.2.1 will hit them; (c) bundling three small wording/skill edits into one PR is less ceremony than three separate proposals.
- **Cut the tag and skip both fixes entirely.** Maximal ship-speed. Rejected for the same reasons — v0.2.0 is the load-bearing pin point.
- **Ship the wording fix and the skill fix in separate PRs.** Cleaner per-commit narrative. Rejected because they are both ~5-line edits with no interdependencies and no interlocked architecture risk; the cost of two PRs (review overhead, two openspec proposals, two CI runs) exceeds the cost of bundling. The "PR-N+1 archives PR-N" housekeeping cadence already pre-existed in this workspace for exactly this kind of bundling.
- **Generalise the SVG-font fix into `scripts/validate-diagrams.sh` (Phase D) so the pre-commit catches future drift.** Best long-term answer. Rejected here for sequencing — Phase D has its own non-trivial design questions (headless SVG-renderer vs metadata-proxy; contrast-floor checks); bundling it into this housekeeping PR would inflate scope significantly. Tracked as Phase D in `architecture/diagrams/INDEX.md`.

## Impact

- **Repos affected:** the architecture repo only in this PR. After `v0.2.0` is tagged, consumers MAY adopt at their next routine `architecture_ref` bump; nothing forces them.
- **Layers / profiles affected:** none.
- **Standards affected:** `standards/diagramming-conventions.md` — one paragraph rewritten in §What this standard does NOT mandate.
- **Skills affected:** `.agents/skills/drawio/SKILL.md` — three additive edits documenting `--embed-svg-fonts false`. Shims under `.claude/skills/drawio/` and `.codex/skills/drawio/` delegate to canonical and need no change.
- **Templates affected:** none.
- **Cross-repo contracts:** none. Both fixes are documentation/skill polish; no normative contract surface changes.
- **Security-boundary impact:** none.

## Affected consumers (Tier 2/3 only)

_None._

Both substantive changes are documentation/skill polish — opt-in, additive, no migration required:

- The standard's wording fix tells consumers about a file that already exists (PR #23 shipped it) and a workflow that already works. No consumer action required.
- The `drawio` skill update is a recommendation, not a new MUST. Existing diagrams (e.g., `platform-edge`'s step-1) are grandfathered per PR #22's §Grandfathering and migration; the recommendation applies only to *new* SVG exports going forward.

Cutting the `v0.2.0` tag itself is a no-op for any consumer that doesn't choose to bump its `architecture_ref` pin.

Per `team-os/cross-repo-governance.md` §Dependency-record linkage, a record is required only when a Tier 2 change "has downstream impact." Opt-in additive surface without forced migration does not qualify. This matches the PR #22 and PR #23 precedents.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`.
- **`deprecation_window:`** `n/a` — additive change.
- **Migration steps:**
  1. Merge this PR. The standard's wording is correct, the skill no longer ships an SVG-bloating default, and both prior proposals are archived.
  2. Cut `git tag v0.2.0` at main HEAD. Push the tag. Draft release notes (see §Release notes draft below).
  3. Consumers MAY bump their `architecture_ref` pin from `v0.1.1` to `v0.2.0` at their next routine PR. Nothing forces them.

## Completion criteria

`completion_state: architecture-complete`

- `standards/diagramming-conventions.md` §What this standard does NOT mandate paragraph rewritten to describe the swatch-and-copy workflow that PR #23 actually shipped.
- `.agents/skills/drawio/SKILL.md` updated in three places (§Procedure step 4, §Supported export formats SVG row, §Locating the CLI flags list) to recommend `--embed-svg-fonts false` for committed SVG exports.
- `bash scripts/sync-agent-skills.sh --check`: PASS (shims delegate to canonical; no drift).
- `openspec/archive/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` exists with `status: accepted`, `merged_pr: 22`.
- `openspec/archive/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/` exists with `status: accepted`, `merged_pr: 23`.
- `openspec/README.md` §Archived proposals lists both with their merge-PR numbers; §Current proposals lists this housekeeping proposal and is otherwise empty (or lists only future post-v0.2.0 proposals).
- All 19 pre-commit hooks pass.
- `openspec-triage.sh`: Tier 2 with proposal present.
- `v0.2.0` tag NOT cut in this PR — the tag is cut **after** this PR merges, at main HEAD, as a post-merge action.

## Release notes draft (for the `v0.2.0` tag cut after this PR merges)

```
v0.2.0 — Enterprise-grade diagramming kit

Diagramming-conventions standard upgraded with contrast floor, paired light
fills per layer, connector vocabulary, seven-archetype table, C4 palette,
iconography baseline, and mandatory legend (PR #22). Workspace style
library and canonical eight-layer control-model reference diagram shipped
(PR #23). Standard's deferred-to-Phase-C wording fixed and drawio skill
updated to recommend --embed-svg-fonts false for committed SVG exports
(PR #N this PR).

No breaking changes. Existing consumer diagrams are grandfathered.
Consumers MAY bump architecture_ref from v0.1.1 to v0.2.0 at their next
routine PR; nothing forces it.
```

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete file edits and rationale per file.
- [`tasks.md`](tasks.md) — execution plan and definition of done.
- **PR #22 (Phase A+B):** the proposal it ships under is archived by this PR — [`../../archive/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/`](../../archive/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/).
- **PR #23 (Phase C):** the proposal it ships under is archived by this PR — [`../../archive/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/`](../../archive/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/).
- No ADRs — wording fix and skill polish are conventions, not foundational architectural trade-offs.
- No dependency records — opt-in additive; no consumer forced.
