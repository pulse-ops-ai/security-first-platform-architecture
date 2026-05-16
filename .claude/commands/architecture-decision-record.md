---
argument-hint: "[short title of the decision]"
---

# Architecture decision record

Draft a new ADR using the template. Canonical procedure: [`../../.agents/skills/architecture-decision-record/SKILL.md`](../../.agents/skills/architecture-decision-record/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. The user input is the short, kebab-case title (e.g., `adopt-verified-permissions-for-l4`). If absent, ask the user.
2. Scan `docs/decisions/` for existing `ADR-NNNN-*.md` files; the next number is `max(NNNN) + 1`, zero-padded to 4 digits.
3. Copy [`../../templates/adr/ADR-template.md`](../../templates/adr/ADR-template.md) to `docs/decisions/ADR-NNNN-<short-title>.md`.
4. Prompt the user to fill in:
   - **Status:** start at `proposed`.
   - **Context:** the situation that forced the decision (be specific — not "we needed authorization" but "we needed relationship-based authorization with sub-millisecond latency").
   - **Decision:** one paragraph, present tense.
   - **Consequences:** positive, negative, neutral.
   - **Alternatives considered:** at least two, with explicit "why not chosen" reasons.
   - **References:** OpenSpec proposal driving the decision, related PRs, prior ADRs.
5. Add the new ADR to `docs/decisions/INDEX.md`.
6. Remind the user: ADRs are immutable once accepted. Reverse via a new ADR that supersedes.

## Guardrails

- Don't write an ADR for purely preferential decisions with no real trade-off.
- Don't skip the "Alternatives considered" section. A decision with no alternatives is suspicious.
- Tier 3 OpenSpec proposals MUST produce an ADR — if one doesn't exist yet, this is the moment to write it.
