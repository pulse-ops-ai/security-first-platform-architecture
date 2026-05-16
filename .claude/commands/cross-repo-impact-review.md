---
argument-hint: "[optional: base ref, default origin/main]"
---

# Cross-repo impact review

Run the `cross-repo-impact-review` skill against the current branch. Canonical procedure: [`../../.agents/skills/cross-repo-impact-review/SKILL.md`](../../.agents/skills/cross-repo-impact-review/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. Resolve the base ref (default `origin/main`) and enumerate touched architecture-repo artifacts.
2. Discover sibling repos present locally per `team-os/workspace-model.md` (trupryce, findevil, levelup-platform, splunk-agentic-ops, plus any other `../*/AGENTS.md`).
3. For each present sibling, grep for references to each touched artifact and inspect the sibling's `security-first-adoption.md` for matching `pending_openspec_changes` / `cross_repo_dependencies` entries.
4. For each affected sibling, confirm a dependency record exists in `portfolio/dependencies/`. Tier 2/3 with no record → `BLOCK`.
5. Return the structured report shape defined in the skill.

## Guardrails

- Do not silently merge a Tier 2/3 change without dep records for affected consumers.
- Flag siblings not checked out locally as "not verified" — don't assume zero impact.
- This command does NOT edit other repos; report only.
