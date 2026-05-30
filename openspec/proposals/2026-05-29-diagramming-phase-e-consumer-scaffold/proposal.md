---
tier: 2
status: in_review
completion_state: architecture-complete
opened: 2026-05-29
target_decision_date: 2026-06-05
authors:
  - "@mike"
---

# OpenSpec Proposal: Diagramming Phase E — consuming-repo `docs/diagrams/` scaffold + CI enforcement

## Problem

The diagramming kit is complete on the architecture-repo side (standard, style library, canonical reference, archetype templates, validator). But a **consuming repo** copied from `templates/consuming-repo/` gets none of it wired in: there is no `docs/diagrams/` directory, no starter index telling the team where diagrams go or how to author them, no `.gitignore` for the drawio autosave files that surfaced during platform-edge's diagram work, and — most importantly — **no CI enforcement**. `validate-diagrams.sh` (Phase D) runs in the architecture repo's own CI and pre-commit, but a consumer's CI never invokes it, so a consumer can commit a diagram with no paired SVG or no footer and nothing catches it.

The result: every consumer rediscovers the diagram workflow from scratch (where does it go? how do I export? what does CI check?), and the validator the kit just shipped does not actually protect consumer diagrams. Phase E — the last deferred piece — closes both gaps.

## Proposed change

Two parts: a **scaffold** in the consumer template, and a **CI wire-up** in the shared reusable workflow.

### Scaffold (`templates/consuming-repo/`)

- `docs/diagrams/INDEX.md` (new) — a starter index: how to add a diagram (copy an archetype template → fill placeholders → export paired SVG → cite source-of-truth + date → add a row), a reference-diagrams table with one example row to replace, the conventions (paired SVG, footer, one-archetype-per-diagram, 90-day review), and an **Enforcement** section pointing at the CI + the local one-liner. It tells consumers that *vendor-named* deployment diagrams belong in their repo (not the vendor-neutral architecture repo).
- `.gitignore` (new) — a starter ignore file folding the drawio autosave pattern (`.$*.drawio.bkp` / `.dtmp`) that bit platform-edge, plus the usual secret / editor / venv noise. Consumers extend it for their stack.
- `docs/INDEX.md` (modified) — adds `diagrams/` to the Sections list.

### CI enforcement (reusable `docs-healthcheck.yml`)

The `docs-healthcheck` reusable workflow already sparse-checks-out the architecture repo's `scripts/` directory in consumer mode and runs `validate-doc-indexes.sh`. Phase E adds a parallel **Run validate-diagrams** step that runs `validate-diagrams.sh .` against the caller's tree, using the same self-vs-consumer script-path discrimination. Full-scan mode (stale footer = warning; contrast = warning; **missing SVG / missing footer = failure**). It no-ops cleanly when the consumer has no `docs/diagrams/`, and **skips gracefully** when the pinned `architecture_ref` predates v0.3.0 (the script isn't there to run). The workflow's `paths:` trigger gains `**/*.drawio`, `**/*.svg`, and `scripts/validate-diagrams.sh`.

Because the workflow is **versioned with the architecture repo**, existing consumers pinned at `v0.2.0` are unaffected until they bump to `v0.3.0` — no surprise CI breakage. The architecture repo's own self-CI picks up the new step immediately (and passes — the eight-layer diagram has its SVG + footer).

## Alternatives considered

- **Scaffold only; no CI wire-up.** Matches the literal deferred-scope note ("stub `docs/diagrams/` + starter `INDEX.md`"). Rejected: a scaffold with no enforcement is decorative — the consumer gets a folder and a README but the validator the kit just shipped still never runs on their diagrams. The wire-up is what makes Phase D real for consumers, and it's a near-exact mirror of the existing `validate-doc-indexes` step.
- **Add `validate-diagrams` as a repo-local pre-commit hook in the consumer template** (instead of CI). Rejected: the consumer template deliberately keeps local hooks fast and generic and hands repo-specific validation to CI via the reusable workflows (the script lives in the architecture repo and is sparse-checked-out, so a consumer can't vendor a tweaked copy and still pass — the same integrity property `validate-doc-indexes` relies on). CI is the right layer.
- **A new dedicated `diagrams-healthcheck.yml` reusable workflow.** Cleaner separation. Rejected: it would need its own consumer thin-caller (more adoption surface, another file consumers must add), for a check that is naturally "are the docs healthy?" `docs-healthcheck` already owns that question and already does the sparse-checkout; extending it is lower-friction for consumers.
- **Ship a real example diagram in the template** (not just an index). Rejected: a real diagram invites copy-paste of placeholder content into production; the architecture repo's archetype templates are the thing to copy. The index points there.

## Impact

- **Repos affected:** the architecture repo ships the scaffold + workflow change. Consumers inherit both when they copy/refresh the template and bump to `v0.3.0`.
- **Standards affected:** none. E is scaffold + CI wiring; the rules are unchanged.
- **Skills affected:** none.
- **Templates affected:** `templates/consuming-repo/` gains `docs/diagrams/INDEX.md` and `.gitignore`; `docs/INDEX.md` updated.
- **CI:** the reusable `docs-healthcheck.yml` gains a `validate-diagrams` step. **Blast radius:** every consumer that invokes `docs-healthcheck.yml@v0.3.0`. Mitigated by (a) mirroring the proven `validate-doc-indexes` step exactly, (b) the pre-v0.3.0 graceful-skip, (c) full-scan mode so only the two hard checks (SVG, footer) can fail, (d) consumers opting in via their `architecture_ref` bump.
- **Security-boundary impact:** none.

## Affected consumers (Tier 2/3 only)

_None forced._ Existing consumers at `v0.2.0` see no change until they bump. On bump to `v0.3.0`, a consumer with diagrams gets CI enforcement of rules the standard already mandated; a consumer without `docs/diagrams/` sees the step no-op. `platform-edge` (the one consumer with a diagram) already ships a paired SVG and a footer, so its `docs-healthcheck` stays green (its ribbon-label contrast is a warning, not a failure). No dependency record required — additive scaffold + CI enforcing existing MUSTs; consumer adoption is opt-in via the ref bump. Matches the PR #19 reusable-CI-baseline precedent.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`.
- **`deprecation_window:`** `n/a` — additive.
- **Migration steps:**
  1. Merge this PR (stacked on D). Scaffold + workflow step land.
  2. `v0.3.0` is cut in the v0.3.0 housekeeping PR after C.2 + D + E land.
  3. Consumers get the scaffold by re-copying/refreshing `templates/consuming-repo/`, and the CI step by bumping their `architecture_ref` to `v0.3.0`. Both optional, at their cadence.

## Completion criteria

`completion_state: architecture-complete`

- `templates/consuming-repo/docs/diagrams/INDEX.md` and `.gitignore` exist; `docs/INDEX.md` references `diagrams/`.
- `docs-healthcheck.yml` runs `validate-diagrams` in both self and consumer mode, with the pre-v0.3.0 graceful skip.
- `validate-doc-indexes.sh` still passes on the template tree (the new index is referenced, not orphaned).
- `pre-commit run --all-files`: 20/20 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — file-by-file detail.
- [`tasks.md`](tasks.md) — execution plan.
- **Stacked on:** D (`validate-diagrams.sh`) — E wires D into consumer CI. Merge order: C.2 → D → E.
- **Completes the v0.3.0 set** (C.2 + D + E). After E, the v0.3.0 housekeeping PR archives the three proposals and cuts the tag.
- Folds the old "B3" item (consumer-template drawio-autosave `.gitignore`) that was reassigned from the v0.2.1 clarifications to here.
- No ADRs — scaffold + CI wiring.
- No dependency records — additive; opt-in.
