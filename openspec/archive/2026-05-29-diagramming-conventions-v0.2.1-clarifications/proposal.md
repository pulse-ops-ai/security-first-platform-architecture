---
tier: 2
status: accepted
completion_state: architecture-complete
opened: 2026-05-29
target_decision_date: 2026-06-05
accepted_date: 2026-05-29
archived_date: 2026-05-29
merged_pr: 26
authors:
  - "@mike"
---

# OpenSpec Proposal: diagramming-conventions v0.2.1 clarifications

## Problem

Applying the v0.2.0 diagramming standard to a real consumer diagram — `platform-edge`'s `consumer-l1-l2-passthrough` topology, refreshed against the new vocabulary in platform-edge PR #5 — surfaced two places where the standard either contradicts itself or under-specifies, forcing the diagram author to depart from the literal text:

1. **The future-ribbon label-colour rule contradicts the contrast floor.** `standards/diagramming-conventions.md` §Layer ribbons says a "future / placeholder" ribbon should use *"the per-layer stroke colour for the label text."* But §Text colour and contrast §Common contrast failures says *"Light layer-ribbon stroke (e.g. `#d6b656` gold) as the only colour for label text … fails AA."* The per-layer strokes are mid-tones tuned to read as a **border**; as **label text** on their own light paired fill they fail the WCAG-AA floor the same standard mandates (e.g. L3 `#82b366` green on `#e8f0e3`, L4 `#d6b656` gold on `#f5eed7` both render as low-contrast green-on-green / gold-on-gold). A conformant author following §Layer ribbons literally produces a diagram that fails §Text colour and contrast. We hit exactly this — the refreshed platform-edge ribbon labels were hard to read until darkened by hand.

2. **The step-badge anchor rule has no position for full-width ribbons.** §Step-number badges gives two anchor choices: *"midpoint of the edge, or top-right corner of the activated container."* Neither fits a step that activates a **whole horizontal layer ribbon** whose label already spans the ribbon's width — there is no "container corner" that isn't on top of the label, and there is no single edge. In the platform-edge diagram the badges for the future L3 / L4 / L5 ribbons had to be anchored at the **left edge of the ribbon**, a position the standard does not name, and the badges for the in-flow edges (step 1, step 6) collided with the edge labels until nudged by hand.

Both are small, but they are the kind of gap that makes "conformant to the standard" a judgement call instead of a mechanical check — and they will recur for the next consumer that draws a staged-rollout trust-zone diagram. Better to fix the text now, while the evidence is fresh, than to let every consumer re-discover the same two snags.

## Proposed change

A patch-level (`v0.2.1`) clarification of `standards/diagramming-conventions.md`. Two edits plus a consistency fix. No new vocabulary, no new MUSTs beyond making the existing AA floor win where it was being contradicted.

### B1 — Future-ribbon label colour

§Layer ribbons "Rendering rule for future / placeholder ribbons" drops *"and the per-layer stroke colour for the label text"* and instead specifies the label text is **`#222222` (bold)**, with the per-layer colour identity carried by the dashed stroke border and the tinted fill. The §Common contrast failures bullet is extended to call out the paired-fill case explicitly (not just "on a white background"). This removes the contradiction in favour of the contrast floor.

### B2 — Step-badge anchor for full-width ribbons

§Step-number badges gains a third anchor option — **left edge of a full-width horizontal layer ribbon**, immediately left of the ribbon label, with a reserved ~28px gutter — plus a one-line rule that when any anchor would land on an edge label, give the edge label `labelBackgroundColor=#ffffff` and offset the badge (or move to the next-best anchor). This names the position the platform-edge diagram already had to use and gives a deterministic collision rule.

Both edits note that the v0.2.0 wording is being corrected and that **existing diagrams are grandfathered** (the §Grandfathering and migration clause already covers this; we restate it inline so the correction does not read as invalidating anything).

## Alternatives considered

- **Leave the standard as-is; treat the contradiction as author's discretion.** Rejected: the whole point of the standard is that "conformant" is mechanical, not a judgement call. A standard that contradicts itself trains authors to ignore it.
- **Keep the per-layer colour on the label but bold-and-darken the stroke colour into an AA-passing variant per layer** (e.g. a second "label-safe" column in the layer table). Rejected: that's a second palette to maintain and verify, and it buys only a faint colour cue that the dashed border + tinted fill already provide. `#222222` bold is simpler, always passes, and matches how the reference examples (and the MLOps-style diagrams the team likes) label boxes.
- **Fold these into the v0.3.0 work (templates / validate-diagrams.sh) instead of a standalone v0.2.1.** Rejected: D (`validate-diagrams.sh`) will *enforce* the contrast floor, so the floor's own wording must be self-consistent *before* D ships, or D would flag diagrams that follow §Layer ribbons literally. B is a prerequisite for D, and it is small enough to ship and tag on its own.
- **Add the third badge anchor as a free-form "wherever it reads best" note.** Rejected: "wherever it reads best" is exactly the non-determinism we are removing. Naming the position + a collision rule keeps it mechanical.

## Impact

- **Repos affected:** the architecture repo only. After `v0.2.1` is tagged, consumers may adopt at their next routine `architecture_ref` bump.
- **Layers / profiles affected:** none.
- **Standards affected:** `standards/diagramming-conventions.md` — two clarifications + one consistency fix. No other standard changes.
- **Skills affected:** none. The `drawio` skill references the standard; it does not enumerate the ribbon-label or badge-anchor rules.
- **Templates affected:** none in this PR. (The v0.3.0 archetype templates — Phase C.2 — will be authored against this clarified text.)
- **Cross-repo contracts:** none. Documentation clarification.
- **Security-boundary impact:** none.

## Affected consumers (Tier 2/3 only)

_None._

Additive clarification; the new wording makes the existing AA floor win where it was contradicted. Existing diagrams (e.g. `platform-edge`'s refreshed `consumer-l1-l2-passthrough`, which already uses `#222222`-style readable labels and a left-edge badge anchor) are grandfathered and already consistent with the clarified text. No consumer is forced to act. Per `team-os/cross-repo-governance.md` §Dependency-record linkage, no dependency record is required for an opt-in additive clarification. Matches the PR #22 / #23 precedent.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`.
- **`deprecation_window:`** `n/a` — clarification of existing rules.
- **Migration steps:**
  1. Merge this PR. The standard is self-consistent.
  2. Cut `v0.2.1` at main HEAD (post-merge), or fold the tag into the next housekeeping PR — see `tasks.md` §Post-merge.
  3. Consumers may adopt at their next routine `architecture_ref` bump. `platform-edge` is already consistent with the clarified text from its PR #5 refresh; no action needed.

## Completion criteria

`completion_state: architecture-complete`

- §Layer ribbons future-ribbon rule no longer instructs colouring the label text with the per-layer stroke; specifies `#222222` bold.
- §Common contrast failures bullet covers the paired-fill case, not just white.
- §Step-number badges has a third anchor option (full-width ribbon left edge) and a collision rule.
- All 19 pre-commit hooks pass.
- `openspec-triage.sh`: Tier 2 with proposal present.
- No skill / template / dependency-record changes.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete before/after text.
- [`tasks.md`](tasks.md) — execution plan + post-merge tag.
- **Evidence:** `platform-edge` PR #5 (diagram visual refresh) — the real artefact that surfaced both gaps.
- No ADRs — wording clarification, not a foundational trade-off.
- No dependency records — opt-in additive.
- **Prerequisite for:** D (`validate-diagrams.sh`, v0.3.0), which enforces the contrast floor and therefore needs the floor's wording self-consistent first.
