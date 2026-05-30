# OpenSpec Change: v0.3.0 housekeeping

Companion to [`proposal.md`](proposal.md).

## Files moved (`git mv`, history preserved)

| From `openspec/proposals/` | To `openspec/archive/` | Frontmatter added |
|---|---|---|
| `2026-05-28-v0.2.0-housekeeping/` | same name | `status: accepted`, `accepted_date: 2026-05-28`, `archived_date: 2026-05-29`, `merged_pr: 24` |
| `2026-05-29-diagramming-conventions-v0.2.1-clarifications/` | same name | `…accepted`, `2026-05-29`, `2026-05-29`, `merged_pr: 26` |
| `2026-05-29-diagramming-phase-c2-archetype-templates/` | same name | `…accepted`, `2026-05-29`, `2026-05-29`, `merged_pr: 27` |
| `2026-05-29-diagramming-phase-d-validate-diagrams/` | same name | `…accepted`, `2026-05-29`, `2026-05-29`, `merged_pr: 28` |
| `2026-05-29-diagramming-phase-e-consumer-scaffold/` | same name | `…accepted`, `2026-05-29`, `2026-05-29`, `merged_pr: 29` |

Only `proposal.md` frontmatter changes in each (the `status` flip + three date/PR fields, inserted after `target_decision_date:`). `change.md` / `tasks.md` move unchanged, matching the existing archive convention.

## Files modified

### `openspec/README.md`

- **Current proposals:** the five entries removed; replaced by the single `2026-05-29-v0.3.0-housekeeping` entry.
- **Archived proposals:** five new entries appended (after the PR #23 / phase-c entry), each with merge-PR number and tag annotation (`v0.2.0` for #24, `v0.2.1` for #26, `v0.3.0` for #27/#28/#29).

## Files added

### `openspec/proposals/2026-05-29-v0.3.0-housekeeping/`

This proposal (`proposal.md`, `change.md`, `tasks.md`).

## Files NOT modified

- `standards/`, `.agents/skills/`, `templates/`, `scripts/`, `architecture/`, `.github/workflows/` — no functional change; this is archive bookkeeping. (The release *content* already merged in PRs #24–#29.)

## Contract changes

**None.** File moves + index update.

## Rollback

`git mv` the five back to `openspec/proposals/`, revert the frontmatter and `README.md`. Tags, once pushed, are deleted with `git push origin :refs/tags/vX.Y.Z` (avoid after consumers pin; prefer a follow-up patch tag).

## Verification

- `bash scripts/validate-doc-indexes.sh .`: PASS — the archived proposals remain indexed from `openspec/README.md`; nothing orphaned.
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 20/20 PASS.
- `openspec-triage.sh origin/main`: classification recorded (Tier 1 or Tier 2; proposal present either way).
- Post-merge: `git tag v0.2.1 f3333ee && git tag v0.3.0 <this-PR-merge-sha>`; `git push origin v0.2.1 v0.3.0`; `git ls-remote --tags` shows both.
