# OpenSpec Change: Diagramming Phase E — consuming-repo `docs/diagrams/` scaffold + CI enforcement

Companion to [`proposal.md`](proposal.md).

## Files added

### `templates/consuming-repo/docs/diagrams/INDEX.md`

Starter index for a consumer's diagrams:
- "How to add a diagram" — copy an architecture-repo archetype template → fill `<placeholders>` → export the paired SVG (`-e --embed-svg-fonts false`) → cite source-of-truth + `Last reviewed` → add a table row.
- A reference-diagrams table with one example row to replace.
- Conventions (paired SVG, footer, one-archetype-per-diagram, 90-day review).
- "Enforcement" — `validate-diagrams.sh` runs in CI via `docs-healthcheck` (from `architecture_ref ≥ v0.3.0`); the local one-liner `bash ../security-first-platform-architecture/scripts/validate-diagrams.sh .`.
- Notes that **vendor-named** deployment diagrams belong in the consumer repo, not the vendor-neutral architecture repo.

### `templates/consuming-repo/.gitignore`

Starter ignore file. Folds the drawio autosave pattern (`.$*.drawio.bkp`, `.$*.drawio.dtmp`) that surfaced in platform-edge, plus secret (`.env*`), editor, and venv noise. Consumers extend for their stack.

## Files modified

### `templates/consuming-repo/docs/INDEX.md`

- Sections list gains `diagrams/` → `diagrams/INDEX.md`.

### `.github/workflows/docs-healthcheck.yml`

- **Header + name comment:** notes it now also validates reference diagrams.
- **`paths:` trigger:** adds `**/*.drawio`, `**/*.svg`, `scripts/validate-diagrams.sh`.
- **"Determine script path" step:** refactored to compute a `scripts_dir` once (self = `scripts`, consumer = `.arch-tools/scripts`) and emit two outputs — `path` (validate-doc-indexes, unchanged behaviour) and `diagrams_path` (validate-diagrams). The self-vs-consumer integrity property (consumer mode MUST use the sparse-checked-out architecture script, never a vendored copy) is preserved.
- **New "Run validate-diagrams" step:** `bash <diagrams_path> .` against the caller's tree, guarded by `[[ -f <diagrams_path> ]]` so a pre-v0.3.0 `architecture_ref` (whose sparse-checkout lacks the script) skips cleanly with a message instead of failing.

  Full-scan mode: stale footer = warning, contrast = warning, **missing SVG / missing footer = failure**. No-ops when there are no diagrams.

## Files NOT modified

- `scripts/validate-diagrams.sh` — shipped in D; E only invokes it. No change.
- `standards/diagramming-conventions.md` — D already flipped the references; E adds no rules.
- `templates/consuming-repo/.pre-commit-config.yaml` — local hooks stay fast/generic; diagram validation is handled in CI via the reusable workflow (the same division of labour as `validate-doc-indexes`). No new local hook.
- Consumer thin-caller workflows — unchanged; they already invoke `docs-healthcheck.yml`, which now also runs validate-diagrams.

## Contract changes

**No contract surface changes.** Scaffold + CI wiring enforcing existing standard MUSTs. The reusable-workflow input signature (`architecture_ref`) is unchanged, so existing consumer callers keep working.

## Cross-repo migration steps

None forced — `completion_state: architecture-complete`. Consumers get the scaffold by refreshing the template and the CI step by bumping `architecture_ref` to `v0.3.0`. The workflow is versioned, so `v0.2.0` consumers are unaffected until they bump.

## Rollback

Revert the `docs-healthcheck.yml` step + trigger changes and delete the scaffold files → consumers fall back to no diagram CI + no scaffold (the pre-E state). The reusable-workflow change is the only shared-surface edit; it is a near-exact mirror of the existing `validate-doc-indexes` step and reverts cleanly.

## Verification

- `bash scripts/validate-doc-indexes.sh .`: PASS — the new `docs/diagrams/INDEX.md` is referenced from `docs/INDEX.md`, not orphaned.
- `actionlint` / `check-yaml`: `docs-healthcheck.yml` parses; the two-output step and the guarded run-step are valid.
- **Self-mode dry check:** `bash scripts/validate-diagrams.sh .` from the architecture repo root scans `architecture/diagrams/` (excludes templates/styles) and passes — the same command the workflow's self-mode step runs.
- **Consumer no-op check:** running `validate-diagrams.sh .` in a tree with a `docs/diagrams/` that has only `INDEX.md` (no `.drawio`) → "no reference diagrams … PASS."
- `bash scripts/repo-healthcheck.sh`: PASS (the new `.gitignore` + `docs/diagrams/INDEX.md` are additive; the universal-floor required-file checks still pass).
- `pre-commit run --all-files`: 20/20 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present.
