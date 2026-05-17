# Repo healthcheck

Run the `repo-healthcheck` skill against the **current repo** (the working tree this Claude Code session is operating in). Canonical procedure: [`../../.agents/skills/repo-healthcheck/SKILL.md`](../../.agents/skills/repo-healthcheck/SKILL.md).

## Instructions

1. This command scans the current repo. To audit a different repo, `cd` to that repo's root before invoking the command.
2. Run the script:

   ```bash
   bash scripts/repo-healthcheck.sh
   ```

   The script auto-detects whether it's running in the architecture repo (`standards/repo-contract.md` sentinel present) or a consuming repo, and runs the appropriate set of checks.
3. Parse the output. The script emits `[OK]`, `[INFO]`, `[WARN]`, and `[ERROR]` lines, then a `== Summary ==` block with counts and a `PASS` / `FAIL` verdict.
4. If the script exits non-zero, the canonical SKILL.md describes how to interpret each common finding category.
5. Surface findings to the user verbatim, then summarize: count of errors, count of warnings, and the recommended next action per error category.

## Guardrails

- Treat this as a STRUCTURAL check only. Passing this skill does not imply architectural compliance — for that, use `/architecture-review`.
- Do not edit the repo's files as part of running this command. Report findings; the repo's owner decides the fix.
- Never add a file (e.g., a stub `CLAUDE.md`) just to satisfy a missing-file finding. If the file's presence contradicts the repo's `agent_adapters_in_use:` declarations, the right fix is to align the declaration with reality.
- Adapter directories that exist but route incorrectly (don't reference `AGENTS.md`) are `[ERROR]` findings, not warnings. They mean the adapter is duplicating the contract instead of routing to it.
