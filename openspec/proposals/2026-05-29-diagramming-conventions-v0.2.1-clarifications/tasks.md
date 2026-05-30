---
completion_state: architecture-complete
---

# OpenSpec Tasks: diagramming-conventions v0.2.1 clarifications

Companion to [`proposal.md`](proposal.md) and [`change.md`](change.md).

## Execution plan

| # | Task | Owner | Status | Reference |
|---|------|-------|--------|-----------|
| 1 | §Layer ribbons future-ribbon rule: drop "per-layer stroke colour for the label text"; specify `#222222` bold; note identity carried by border + fill (B1) | @mike | completed | this PR |
| 2 | §Common contrast failures: extend the layer-ribbon bullet to cover the paired-fill case; cross-link §Layer ribbons (B1 consistency) | @mike | completed | this PR |
| 3 | §Step-number badges: add third anchor (full-width ribbon left edge, ~28px gutter) + edge-label collision rule (B2) | @mike | completed | this PR |
| 4 | Write OpenSpec proposal (`proposal.md`, `change.md`, `tasks.md`) | @mike | completed | this PR |
| 5 | Add this proposal to `openspec/README.md` §Current proposals | @mike | completed | this PR |
| 6 | Confirm `pre-commit run --all-files`: 19/19 PASS | @mike | pending | this PR |
| 7 | Confirm `openspec-triage.sh origin/main`: Tier 2 with proposal present | @mike | pending | this PR |
| 8 | Open PR | @mike | pending | this PR |

## Definition of done

### Pre-merge

- [x] §Layer ribbons no longer instructs colouring the future-ribbon label text with the per-layer stroke colour.
- [x] §Common contrast failures names the paired-fill case and points to §Layer ribbons.
- [x] §Step-number badges lists three anchor options + a collision rule.
- [x] `openspec/README.md` §Current proposals lists this proposal.
- [ ] `bash scripts/validate-skills.sh`: PASS.
- [ ] `bash scripts/sync-agent-skills.sh --check`: PASS.
- [ ] `bash scripts/validate-doc-indexes.sh`: PASS.
- [ ] `bash scripts/validate-architecture.sh`: PASS.
- [ ] `bash scripts/repo-healthcheck.sh`: PASS.
- [ ] `pre-commit run --all-files`: 19/19 PASS.
- [ ] `openspec-triage.sh`: Tier 2 with proposal present.
- [x] No ADR (wording clarification).
- [x] No dependency records (opt-in additive).
- [x] No skill / template changes.

## Per-consumer integration tasks

**n/a** — no consumer is required to integrate. `platform-edge`'s refreshed diagram is already consistent with the clarified text.

## Post-merge

- [ ] Cut `v0.2.1` at this PR's merge commit (`git tag v0.2.1 <sha> && git push origin v0.2.1`), **or** fold the tag into the v0.3.0 housekeeping PR if v0.3.0 (C2 / D / E) lands close behind. Decision at merge time; a standalone `v0.2.1` is fine because B is a prerequisite for D and self-contained.
- [ ] Archive this proposal to `openspec/archive/` in the next housekeeping PR (per the "PR-N+1 archives PR-N" convention), with `status: accepted`, `accepted_date`, `archived_date`, `merged_pr`.
- [ ] D (`validate-diagrams.sh`) consumes this clarified floor — sequence D after this lands so the validator does not flag diagrams that follow the (now-fixed) §Layer ribbons literally.

## Notes

- This is deliberately a **patch** (`v0.2.1`), not a minor: it changes no vocabulary and adds no capability; it makes the existing AA floor win where the v0.2.0 text contradicted it, and names an anchor position authors were already using.
- B is the prerequisite for D in the v0.3.0 set. C2 (archetype templates) should also be authored against this clarified text so the shipped templates do not bake in the contradicted rule.
