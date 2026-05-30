# OpenSpec Change: diagramming-conventions v0.2.1 clarifications

Companion to [`proposal.md`](proposal.md).

## Files modified

### `standards/diagramming-conventions.md`

Three edits, all in the visual-vocabulary body. No structural change.

#### 1. §Layer ribbons — future-ribbon rendering rule (B1)

- **Before.**

  > **Rendering rule for "future / placeholder" ribbons** … use the paired light fill, the per-layer stroke as a dashed border, and the per-layer stroke colour for the label text. This solves the "transparent ribbons on white background are unreadable" failure mode.

- **After.**

  > **Rendering rule for "future / placeholder" ribbons** … use the paired light fill and the per-layer stroke as a dashed border. This solves the "transparent ribbons on white background are unreadable" failure mode.
  >
  > **Label-text colour on a paired-fill ribbon: use `#222222`, not the per-layer stroke colour.** The per-layer stroke colours are mid-tones tuned to read as a *border* against white; as *label text* they fail the §Text colour and contrast AA floor against their own light paired fill (e.g. L3 `#82b366` green on `#e8f0e3`, L4 `#d6b656` gold on `#f5eed7`). The per-layer colour identity is carried by the dashed stroke border and the tinted fill — the label text does not need to repeat it. Keep the label **bold** so the layer name still reads as a heading. (This corrects the v0.2.0 wording … existing diagrams are grandfathered.)

- **Rationale.** Removes the self-contradiction between §Layer ribbons and §Text colour and contrast. The AA floor wins.

#### 2. §Text colour and contrast — common contrast failures bullet (B1 consistency)

- **Before.**

  > - Light layer-ribbon stroke (e.g., `#d6b656` gold) as the only colour for label text on a white background — fails AA.

- **After.**

  > - Light layer-ribbon stroke (e.g., `#d6b656` gold) as the only colour for label text — on a white background **or on its own paired light fill** — fails AA. Use `#222222` for layer-ribbon labels (bold); let the dashed stroke border and tinted fill carry the per-layer colour identity. See §Layer ribbons.

- **Rationale.** The original bullet only named the white-background case; the paired-fill case is where the contradiction actually bit. Cross-links the two sections so they cannot drift apart again.

#### 3. §Step-number badges — anchor options (B2)

- **Before.**

  > - Anchor: midpoint of the edge, or top-right corner of the activated container

- **After.**

  > - Anchor — choose the position that does not overlap a label or line:
  >   - **midpoint of the edge** (default for a connector that activates at that step); or
  >   - **top-right corner of the activated container** (for a box / service); or
  >   - **left edge of a full-width horizontal layer ribbon**, immediately left of the ribbon's label text, when the step activates the whole ribbon and the label already spans the ribbon's width. Reserve a left gutter (~28px) in the label's `x` offset so the badge and the first character of the label do not collide.
  > - Edge labels already carry `labelBackgroundColor=#ffffff` (mandated in §Connectors), so a badge sitting next to a label rests over a white background, not bare line or text. If a badge would still overlap the label *text* itself, offset the badge along the edge or move it to the next-best anchor above so both stay legible.

- **Rationale.** Names the anchor the platform-edge diagram already had to invent (left edge of a full-width ribbon) and adds a deterministic collision rule. Keeps badge placement mechanical.

## Files NOT modified

- `.agents/skills/drawio/SKILL.md`, `mermaid-diagram/` — reference the standard; do not enumerate the ribbon-label or badge-anchor rules. No change.
- `templates/` — the v0.3.0 archetype templates (Phase C.2) will be authored against the clarified text; nothing to change here.
- `architecture/diagrams/` — the canonical eight-layer reference does not use a "future / placeholder" ribbon (it shows the full model), so its labels are unaffected. Verified during this change.
- Any consumer diagram — grandfathered.

## Contract changes

**No contract surface changes.** Clarification of an existing standard; the AA floor it makes consistent was already a MUST in v0.2.0.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. Consumers adopt at their next routine `architecture_ref` bump. `platform-edge` is already consistent with the clarified text.

## Rollback

Revert the three edits → the standard returns to the v0.2.0 wording (self-contradictory but harmless, since the contradiction is between two documentation rules, not a runtime contract). No irreversibility.

## Verification

- `bash scripts/validate-skills.sh`: PASS (no skill changes).
- `bash scripts/sync-agent-skills.sh --check`: PASS.
- `bash scripts/validate-doc-indexes.sh`: PASS.
- `bash scripts/validate-architecture.sh`: PASS (no vendor leakage; the example hex codes are vendor-neutral).
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 19/19 PASS.
- `openspec-triage.sh`: Tier 2 with proposal present.
- **Manual:** re-read §Layer ribbons and §Text colour and contrast back-to-back; confirm no remaining instruction to colour ribbon-label text with the per-layer stroke. Re-read §Step-number badges; confirm three anchor options + collision rule.
