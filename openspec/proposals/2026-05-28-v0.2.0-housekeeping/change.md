# OpenSpec Change: v0.2.0 housekeeping — cut tag, wording fix, skill fix, proposal archives

Companion to [`proposal.md`](proposal.md).

## Files modified

### `standards/diagramming-conventions.md`

- **Path.** `standards/diagramming-conventions.md`, the one paragraph in §What this standard does NOT mandate that describes the workspace style file.
- **Before.**

  > A drawio global-style file is **not yet shipped**; it is deferred to a Phase C follow-up that will publish `architecture/diagrams/styles/workspace.drawio` for consumers to import via *Extras → Edit Diagram Style*. Until then, the vocabulary above is the source-of-truth and individual diagrams set their own styles.

- **After.**

  > Use of any specific style-import mechanism. A workspace style library ships at [`../architecture/diagrams/styles/workspace.drawio`](../architecture/diagrams/styles/workspace.drawio) as a **swatch-and-copy** library (open the file, copy the swatch you want, paste into your working diagram — see [`../architecture/diagrams/styles/README.md`](../architecture/diagrams/styles/README.md) for the workflow). Consumers SHOULD use it to inherit workspace-correct styles without typing hex codes by hand, but the vocabulary above remains the source of truth and diagrams MAY set their own styles directly. A formal `<mxlibrary>` drag-and-drop shape library is a future enhancement tracked alongside `validate-diagrams.sh`.

- **Rationale.** The original paragraph was written before PR #23 shipped and described the workspace style file as something to be imported via *Extras → Edit Diagram Style*. That mechanism does not do what the original author hoped (it sets the style JSON for newly-inserted-unstyled shapes in one diagram at a time, not an importable vocabulary of named ready-to-use shapes). What PR #23 actually shipped is a **swatch-and-copy** library, and PR #23's proposal §Deviation captured the rationale for the workflow choice. This housekeeping edit aligns the standard's wording with the artefact that exists, so the next consumer reading the standard is not misled.

### `.agents/skills/drawio/SKILL.md`

Three additive edits in the canonical skill (no shim changes; shims delegate to canonical and `scripts/sync-agent-skills.sh --check` confirms no drift):

- **§Procedure step 4** — gains a sentence:

  > For SVG, also pass `--embed-svg-fonts false` when the target lives under a committed `docs/diagrams/` or `architecture/diagrams/` directory — drawio's default embeds fonts as base64 and routinely produces files >1 MB that trip repo-level max-file-size pre-commit hooks; setting it false typically drops a full-page export to <100 KB. Editable XML stays embedded; browsers render with system-font fallbacks.

- **§Supported export formats** — the SVG row Notes column extended with `; pass --embed-svg-fonts false for committed SVG to stay under typical 500 KB pre-commit ceilings`.

- **§Locating the CLI** flags list — new entry:

  > `--embed-svg-fonts <true/false>`: embed fonts in SVG (default: `true`). **For committed `docs/diagrams/` or `architecture/diagrams/` SVG, pass `false`** — drawio's default base64-encodes the font glyphs into the SVG, routinely producing files past 500 KB pre-commit ceilings. With it disabled, browsers fall back to system sans-serif (Arial / Liberation Sans / Helvetica). Editable XML stays embedded.

- **Rationale.** PR #23's `eight-layer-control-model.drawio.svg` rendered at 2.0 MB with the skill's default `-e --embed-diagram` flags and dropped to 80 KB with `--embed-svg-fonts false`. That's the difference between failing and passing this repo's 500 KB `check-added-large-files` hook. A fresh consumer agent following the skill verbatim would have hit the same failure. Capturing the recommendation in the canonical SKILL.md propagates to every consumer that uses the skill via its `.claude/skills/` or `.codex/skills/` shim.

## Files moved

### `openspec/proposals/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` → `openspec/archive/`

- **Action.** `git mv` (preserves history).
- **Frontmatter updated.** `status: in_review` → `status: accepted`; added `accepted_date: 2026-05-28`, `archived_date: 2026-05-28`, `merged_pr: 22`.
- **Rationale.** PR #22 merged at commit `5f882b7`. The proposal's own `tasks.md` §Post-merge specified "combine with the `v0.2.0` housekeeping PR" — this is that PR.

### `openspec/proposals/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/` → `openspec/archive/`

- **Action.** `git mv`.
- **Frontmatter updated.** Same treatment with `merged_pr: 23`.
- **Rationale.** PR #23 merged at commit `21feb5b`. Per the "PR-N+1 archives PR-N" workspace convention; this PR is N+1.

### `openspec/README.md`

- **§Current proposals** — both Phase A+B and Phase C entries removed (they are now archived); housekeeping proposal added.
- **§Archived proposals** — two new entries added at the bottom:
  - `archive/2026-05-28-diagramming-enterprise-upgrade-phase-a-b/` — Tier 2, accepted, architecture-complete (merged in PR #22).
  - `archive/2026-05-28-diagramming-phase-c-style-library-and-canonical-diagram/` — Tier 2, accepted, architecture-complete (merged in PR #23).
- **Rationale.** Keeps the README accurate about what's in `proposals/` vs `archive/`.

## Files added

### `openspec/proposals/2026-05-28-v0.2.0-housekeeping/`

This proposal (`proposal.md`, `change.md`, `tasks.md`).

## Files NOT modified

- `.claude/skills/drawio/SKILL.md`, `.codex/skills/drawio/SKILL.md` — shims delegate to canonical; `sync-agent-skills.sh --check` confirms no drift after the canonical edits.
- `.claude/commands/drawio.md` — routes to canonical skill; no flag-level guidance to update.
- `architecture/diagrams/` — the artefacts PR #23 shipped do not change; only the documentation about them does.
- `architecture/diagrams/INDEX.md`, `architecture/diagrams/styles/README.md` — both already describe the swatch-and-copy workflow accurately; PR #23's proposal §Deviation noted that only the standard had drifted, not the diagram-side docs.
- `templates/consuming-repo/` — Phase E expansion ships separately.
- `team-os/`, `portfolio/`, `infra/`, `architecture/profiles/` — unaffected.
- The dependency record `portfolio/dependencies/DEP-2026-05-24-001-platform-edge-onboarding.md` (or its current name) — out of scope per `proposal.md` §Out of scope.

## Contract changes

**No contract surface changes.** Strictly polish:

- Wording fix in standards/ documents an artefact that already exists.
- Drawio skill edit is a recommendation, not a new MUST.
- Proposal archives are filesystem moves, not contract changes.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. Consumers MAY bump their `architecture_ref` pin from `v0.1.1` to `v0.2.0` at their next routine PR after the tag is cut; nothing forces them.

The `v0.2.0` tag is cut **after** this PR merges (post-merge action documented in `tasks.md` §Post-merge), not as part of the diff itself.

## Rollback

Each piece is independently reversible:

- Revert the standard's wording fix → readers see the older "deferred to Phase C / Extras → Edit Diagram Style" paragraph; misleading but not destructive (the workspace file still exists, the README still describes the workflow).
- Revert the `drawio` skill edits → consumers fall back to the pre-PR recommendation (`-e --embed-diagram` only) and produce bloated SVGs that fail the 500 KB hook locally; the canonical eight-layer diagram already shipped in PR #23 with the smaller-SVG flag remains correct on disk.
- Revert the proposal archive moves → `proposals/` regains both proposal directories with their original `status: in_review` frontmatter; the substance is unchanged.

The `v0.2.0` tag, once cut, can be deleted (`git tag -d v0.2.0 && git push origin :refs/tags/v0.2.0`), though doing so after consumers have pinned to it would force re-pin work; prefer to ship `v0.2.0.1` or `v0.2.1` if a fix is needed.

## Verification

- `bash scripts/validate-skills.sh`: PASS (canonical SKILL.md structure unchanged).
- `bash scripts/sync-agent-skills.sh --check`: PASS (no shim drift; shims delegate to canonical).
- `bash scripts/validate-doc-indexes.sh`: PASS.
- `bash scripts/validate-architecture.sh`: PASS.
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 19/19 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present (`standards/` + `.agents/skills/` paths trigger Tier 2; matches intent).
- **Manual visual check (optional):** open `standards/diagramming-conventions.md` and confirm the §What this standard does NOT mandate paragraph now reads as a positive description of the swatch-and-copy library rather than a "deferred / not yet shipped" line.
