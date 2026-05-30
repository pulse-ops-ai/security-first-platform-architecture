---
tier: 2
status: in_review
completion_state: architecture-complete
opened: 2026-05-29
target_decision_date: 2026-06-05
authors:
  - "@mike"
---

# OpenSpec Proposal: Diagramming Phase D — `validate-diagrams.sh`

## Problem

Two of the diagramming standard's rules have been **self-enforced quality bars** with no automation since v0.2.0:

1. **The WCAG-AA contrast floor.** The standard mandates 4.5:1 body / 3:1 large text, but nothing checks it. The platform-edge refresh proved the floor is easy to violate by following the (pre-v0.2.1) §Layer ribbons rule literally — and a human reviewer eyeballing a rendered SVG will not reliably catch a 3.4:1 label.
2. **The source-of-truth footer + quarterly-review cadence.** Every diagram MUST carry a `Last reviewed: YYYY-MM-DD` footer and ship a paired SVG, but a diagram can be edited without bumping the date, or committed without its SVG, and nothing flags it.

The standard has pointed at a "future `validate-diagrams.sh` CI hook" in three places since v0.2.0. The v0.2.1 clarifications (PR #26) removed the self-contradiction in the contrast rules — which was the **prerequisite** for enforcing the floor, because a validator can't enforce a rule the standard contradicts. With that done, Phase D ships the validator.

## Proposed change

Ship `scripts/validate-diagrams.sh` + a pre-commit hook, and flip the standard / INDEX / scripts-README references from "future" to "shipped in v0.3.0."

### `scripts/validate-diagrams.sh`

Per **reference diagram** (a `.drawio` under `architecture/diagrams/` or, in a consuming repo, `docs/diagrams/` — auto-detected by the `standards/repo-contract.md` sentinel, same as `repo-healthcheck.sh`; the `templates/` and `styles/` subdirs are excluded):

- **Paired SVG** — `<name>.svg` or `<name>.drawio.svg` must exist. Missing → **error**.
- **Footer present + fresh** — the `.drawio` must contain `Last reviewed: YYYY-MM-DD`. Missing → **error**. Stale beyond `--stale-days` (default 90): **error when the diagram is in the changeset** (you edited a stale diagram → re-review and bump), **warning on a full scan** (surfaced at the quarterly pass, doesn't block unrelated commits).
- **Contrast lint (WCAG 2.1 AA)** — for each text cell, compute the contrast ratio of `fontColor` against its background (the cell's `fillColor`, or white when the cell has no fill), pick the floor by text size (4.5:1 body / 3:1 large = ≥18pt or ≥14pt bold), and flag ratios below it. Findings are **warnings by default** and **errors under `--strict`**, because the white-background assumption can't see a coloured shape sitting behind a standalone text element — so a true contrast failure is flagged, but the tool won't hard-block on a possible false positive without the author opting in.

CLI: `validate-diagrams.sh [--strict] [--stale-days N] [TARGET ...]`. No target → full scan of the repo's diagrams directory; a directory → scan that tree; `.drawio` paths → changeset mode (how the pre-commit hook invokes it). Exit `0` pass / `1` fail / `2` invocation error. Uses GNU `date -d` (Linux CI/dev).

### Pre-commit hook

A `validate-diagrams` local hook, `pass_filenames: true`, `files: ^(architecture/diagrams/|docs/diagrams/).*\.drawio$`. It runs in changeset mode (default, non-strict) so: missing SVG / missing footer / **stale footer on an edited diagram** block the commit; contrast findings print as warnings. This is the 20th pre-commit hook; CI coverage comes for free via the existing pre-commit workflow.

### Documentation flips

`standards/diagramming-conventions.md` §Drift mitigation point 3, the §Text-colour contrast-floor note, and the §What-this-standard-does-NOT-mandate line; `architecture/diagrams/INDEX.md` §Drift mitigation + Phase-C scope; `scripts/README.md`. All change "future / not in the first release" → "shipped in v0.3.0," with the actual behaviour and limitations.

### First finding (worth surfacing)

Running the validator over the repo's one reference diagram — the canonical `eight-layer-control-model.drawio` — produces **0 errors, 5 contrast warnings**: its layer-ribbon labels use the per-layer stroke colours on white (1.97–3.96:1), the exact pattern v0.2.1 §Layer ribbons now says to render as `#222222` bold. The diagram predates v0.2.1 and is **grandfathered** (warning, not error), but it means the canonical reference does not yet exemplify the clarified rule. Refreshing it to `#222222` bold labels is a recommended follow-up (a small visual change to the C.3 artefact), deliberately **not** bundled here so D stays a tooling PR.

## Alternatives considered

- **Make the contrast lint a hard failure (error) by default.** Strongest enforcement. Rejected: the background-resolution heuristic (white when a text cell has no fill) will false-positive on light text correctly placed over a dark shape, and hard-blocking commits on a heuristic false positive is worse than a visible warning. `--strict` exists for repos/CI lanes that want the hard gate; the canonical-reference scan above is exactly why default-error would be wrong today.
- **Do real per-pixel contrast on the rendered SVG/PNG.** Most accurate (resolves actual backgrounds). Rejected for v1: needs a headless rasteriser + image analysis, a heavy dependency for a doc repo. The XML-level heuristic catches the documented failure modes (the whole point) at zero new dependencies; pixel-accurate contrast is a future enhancement.
- **Implement the full "diagram OR its cited doc changed" staleness check.** Matches the standard's wording exactly. Rejected for v1: mapping a diagram to its cited docs and diffing both needs parsing the footer's free-text citation and a git-history walk. The high-value 80% (edited-diagram-with-stale-date, missing footer, missing SVG) ships now; the cited-doc cross-check stays a documented reviewer responsibility.
- **Use `gawk`/`strtonum` for the hex math.** Cleaner awk. Rejected: CI/dev may have `mawk` (it does here — `strtonum` is undefined). Hex is parsed to decimal in bash and passed to awk as integers, so the contrast math is portable.

## Impact

- **Repos affected:** the architecture repo ships the script + hook. Consuming repos inherit it when they adopt the pre-commit config (the script auto-detects consumer mode and scans `docs/diagrams/`).
- **Standards affected:** `standards/diagramming-conventions.md` — three "future" references flipped to "shipped." No rule changes (the rules were already MUSTs; D enforces them).
- **Skills affected:** none. The `drawio` skill already tells authors to keep the footer + paired SVG; D enforces it.
- **CI:** +1 pre-commit hook (20 total). No new workflow file — the existing pre-commit workflow runs it.
- **Cross-repo contracts:** none. A lint, not a contract.
- **Security-boundary impact:** none.

## Affected consumers (Tier 2/3 only)

_None forced._ The hook only runs on repos that have diagrams under `docs/diagrams/`; for those, it enforces rules the standard already mandated. A consumer with an existing diagram that trips a **hard** check (no paired SVG, no footer) would see it fail on their next diagram-touching commit — but that is a pre-existing standard violation, and existing diagrams are otherwise grandfathered on the soft (contrast / staleness-on-full-scan) checks. No dependency record required (additive tooling; the hard checks restate existing MUSTs). Matches the PR #19 precedent (the reusable-workflow + pre-commit baseline shipped without per-consumer records).

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`.
- **`deprecation_window:`** `n/a` — additive tooling.
- **Migration steps:**
  1. Merge this PR (stacked on C.2). The script + hook + doc flips land.
  2. `v0.3.0` is cut in the v0.3.0 housekeeping PR after C.2 + D + E land.
  3. Consumers get the hook at their next `architecture_ref` bump + pre-commit-config refresh. The script no-ops cleanly when `docs/diagrams/` is absent.

## Completion criteria

`completion_state: architecture-complete`

- `scripts/validate-diagrams.sh` exists, executable, `shellcheck`-clean, with the three checks and the documented CLI.
- The `validate-diagrams` pre-commit hook is wired and passes on the current tree (eight-layer: 0 errors, contrast warnings only).
- Standard / `architecture/diagrams/INDEX.md` / `scripts/README.md` references flipped to "shipped in v0.3.0."
- `pre-commit run --all-files`: 20/20 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — file-by-file detail.
- [`tasks.md`](tasks.md) — execution plan.
- **Stacked on:** the C.2 archetype-templates branch (so the script's `templates/` exclusion is exercised against the real templates). Merge order: v0.2.1 (done) → C.2 → D → E.
- **Prerequisite (merged):** v0.2.1 clarifications (PR #26) — made the contrast rules self-consistent so the floor can be enforced.
- **Recommended follow-up:** refresh `eight-layer-control-model.drawio` ribbon labels to `#222222` bold (the validator's first finding).
- No ADRs — tooling, not a foundational trade-off.
- No dependency records — additive; hard checks restate existing MUSTs.
