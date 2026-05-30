# OpenSpec Change: Diagramming Phase D — `validate-diagrams.sh`

Companion to [`proposal.md`](proposal.md).

## Files added

### `scripts/validate-diagrams.sh`

Executable bash gate. Structure:

- **Arg parsing:** `--strict`, `--stale-days N`, `--help`, and `TARGET ...` (directories → full scan; `.drawio` paths → changeset mode).
- **Mode + discovery:** sentinel `standards/repo-contract.md` → architecture repo (`architecture/diagrams/`) vs consumer (`docs/diagrams/`). `find … -name '*.drawio'`, excluding any path under `*/templates/*` or `*/styles/*`. No-ops cleanly (PASS) when the directory or any diagram is absent.
- **Check 1 — paired SVG:** `<name>.svg` or `<name>.drawio.svg` must exist → else error.
- **Check 2 — footer present + fresh:** grep `Last reviewed: YYYY-MM-DD`; missing → error; parse via GNU `date -d`; stale beyond `--stale-days` (default 90) → error in changeset mode / warning on full scan.
- **Check 3 — contrast lint:** `contrast_ratio` parses hex → decimal in bash (`$((16#..))`, mawk-safe) and computes the WCAG relative-luminance ratio in awk; per text cell, `fontColor` vs `fillColor`-or-white, floor by size (4.5 / 3.0), below-floor → warning (error under `--strict`).
- **Summary + exit:** `N diagram(s) checked · E error(s) · W warning(s)`; exit 0 (warnings ok) / 1 (errors) / 2 (bad invocation).

Helper functions (`err`/`warn`/`ok`/`info`, `[ERROR]`/`[WARN]`/`[OK]`/`[INFO]` prefixes) and the sentinel/exit-code conventions match `repo-healthcheck.sh`.

## Files modified

### `.pre-commit-config.yaml`

New `validate-diagrams` local hook after `check-infra-secrets`:

```yaml
      - id: validate-diagrams
        name: validate-diagrams.sh (paired SVG + fresh source-of-truth footer + contrast lint)
        entry: bash scripts/validate-diagrams.sh
        language: system
        pass_filenames: true
        files: ^(architecture/diagrams/|docs/diagrams/).*\.drawio$
```

`pass_filenames: true` → changeset mode (stale footer on an edited diagram blocks; contrast warns). 20th hook; CI coverage via the existing pre-commit workflow.

### `standards/diagramming-conventions.md`

- §Drift mitigation point 3: "CI optional `validate-diagrams.sh` *(future)*" → a full description of the shipped script (the three checks, the changeset-vs-full-scan stale behaviour, `--strict`, the `templates/`/`styles/` exclusion, and the explicit non-goal of cited-doc diffing).
- §Text colour and contrast floor note: "(future) `validate-diagrams.sh` CI hook … self-enforced" → "shipped in `v0.3.0`; lints at commit time, warning by default or `--strict` to fail."
- §What this standard does NOT mandate: dropped the "tracked alongside `validate-diagrams.sh`" tail from the `<mxlibrary>` future-enhancement line (the validator now exists).

### `architecture/diagrams/INDEX.md`

- §Drift mitigation point 3 and the Phase-C scope note flipped from "a future `scripts/validate-diagrams.sh` (Phase D)" to the shipped `v0.3.0` tool with a link.

### `scripts/README.md`

- New table row + a `Running locally` line for `validate-diagrams.sh`.

## Files NOT modified

- `.agents/skills/drawio/`, `mermaid-diagram/` — already instruct authors to keep the footer + paired SVG; D enforces, the skill doesn't change.
- `architecture/diagrams/eight-layer-control-model.drawio` — the validator's first finding (5 contrast warnings; grandfathered). Refreshing its ribbon labels to `#222222` bold is a recommended follow-up, deliberately not bundled (keeps D a tooling PR).
- `architecture/diagrams/templates/`, `styles/` — excluded by the script; unchanged.

## Contract changes

**No contract surface changes.** A lint that enforces existing standard MUSTs; adds no new rule.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. Consumers inherit the hook at their next `architecture_ref` bump + pre-commit refresh; the script no-ops when `docs/diagrams/` is absent.

## Rollback

Remove the hook from `.pre-commit-config.yaml`, delete `scripts/validate-diagrams.sh`, and revert the doc flips → back to the self-enforced quality bar. No diagram becomes invalid; nothing irreversible.

## Verification

- `bash scripts/validate-diagrams.sh` (full scan): PASS — eight-layer, 0 errors, 5 contrast warnings.
- `bash scripts/validate-diagrams.sh --strict architecture/diagrams/eight-layer-control-model.drawio`: FAIL (exit 1) — contrast errors under strict, proving the gate works.
- `bash scripts/validate-diagrams.sh architecture/diagrams/templates`: PASS — 0 diagrams (exclusion works).
- Contrast sanity: `#222222` on `#ffffff` = 15.91:1; `#444444` on `#ffffff` = 9.74:1; `#82b366` on `#e8f0e3` = 2.10:1 (the v0.2.1 fail case); `#ffffff` on `#1168bd` (C4 owned) = 5.62:1.
- `shellcheck scripts/validate-diagrams.sh`: clean (via the pre-commit `shellcheck` hook).
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 20/20 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present.
