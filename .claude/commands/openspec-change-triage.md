---
argument-hint: "[optional: base ref, default origin/main]"
---

# OpenSpec change triage

Run the `openspec-change-triage` skill on the current branch. Canonical procedure: [`../../.agents/skills/openspec-change-triage/SKILL.md`](../../.agents/skills/openspec-change-triage/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. Resolve the base ref (default `origin/main`).
2. Run:

   ```bash
   bash scripts/openspec-triage.sh <base-ref>
   ```

3. Interpret the result:
   - Tier 1 → no OpenSpec required, exit `PASS`.
   - Tier 2/3 with a present, well-formed proposal → exit `PASS` and remind the user that `/cross-repo-impact-review` covers dep-record-per-consumer.
   - Tier 2/3 with no proposal → exit `BLOCK` and show how to scaffold one using `templates/openspec/`.
   - Tier 3 with `architecture-complete` → exit `BLOCK` — Tier 3 must target `adoption-complete`.

4. For Tier 2/3 with consumer impact, prompt the user to also run `/cross-repo-impact-review`. This command does NOT check dep records.

## Guardrails

- Do not soft-pass with "happy to add later" on Tier 2/3.
- Trust the triage script's tier classification; if you believe it's wrong, fix the rule in `scripts/openspec-triage.sh` via an OpenSpec proposal, not ad-hoc.
