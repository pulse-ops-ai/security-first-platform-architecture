---
name: architecture-decision-record
description: Draft a new ADR using the template. Use when a real trade-off was made, when a decision will shape architecture/standards/TeamOS materially, when a Tier 3 OpenSpec proposal has been accepted, or when "see ADR-N" will be the right answer in six months.
---

# Architecture decision record

<!-- no-shim: claude — vendor-neutral procedure; .claude/commands/architecture-decision-record.md invokes canonical directly. -->
<!-- no-shim: codex -->

Capture a non-trivial decision and its rationale in an immutable ADR under `docs/decisions/`. ADRs answer *why* a decision was made; reversing one means writing a new ADR that supersedes it.

## Inputs

- A short description of the decision.
- The trade-off being made and why this option won.
- Optional: links to the OpenSpec proposal or PR that produced the decision.

## Procedure

1. Identify the next ADR number by scanning `docs/decisions/` for existing `ADR-NNNN-*.md` files.
2. Copy [`../../../templates/adr/ADR-template.md`](../../../templates/adr/ADR-template.md) to `docs/decisions/ADR-NNNN-short-title.md`.
3. Fill in:
   - **Title** — short and specific.
   - **Status** — `proposed` initially; move to `accepted` once approved.
   - **Context** — the situation that forced a decision.
   - **Decision** — what was decided, one paragraph, present tense.
   - **Consequences** — positive, negative, and neutral effects.
   - **Alternatives considered** — what else was on the table, and why this won.
   - **References** — related OpenSpec proposals, PRs, ADRs.
4. Add the new ADR to `docs/decisions/INDEX.md`.

## Output

- A new file at `docs/decisions/ADR-NNNN-short-title.md`.
- An updated `docs/decisions/INDEX.md`.
- A summary line for the PR description (title, status, one-sentence decision).

## Guardrails

- Do not write an ADR for purely preferential decisions with no trade-off — that is comment noise.
- Do not edit an ADR after status moves to `accepted`. Reverse it with a new ADR that supersedes the old one.
- Do not skip the `Alternatives considered` section. A decision with no alternatives is suspicious; if only one option was viable, say so explicitly and explain why.

## See also

- [`../../../templates/adr/ADR-template.md`](../../../templates/adr/ADR-template.md)
- [`../../../docs/decisions/INDEX.md`](../../../docs/decisions/INDEX.md)
