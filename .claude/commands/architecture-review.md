---
argument-hint: "[optional: base ref, default origin/main]"
---

# Architecture review

Run the `architecture-review` skill against the current branch's diff. Canonical procedure: [`../../.agents/skills/architecture-review/SKILL.md`](../../.agents/skills/architecture-review/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. Resolve the base ref. If `$ARGUMENTS` is non-empty and looks like a Git ref, use it; otherwise default to `origin/main`.
2. Enumerate the touched files via `git diff --name-only <base>...HEAD` and bucket them per the canonical skill.
3. Run `bash scripts/validate-architecture.sh` and parse `[LEAK]` / `[MISSING]` lines. Each is a `BLOCK`.
4. Walk through the eight-layer assignment checklist for any new or changed component.
5. Apply the profile-consistency, agent-as-client, internal-envelope, tenant-isolation, and observability checks per the skill.
6. Return the report shape defined in the skill, ending with an overall recommendation.

## Coordination with other skills

- For security-stack changes, also invoke `/security-control-review` — this command does NOT replace it.
- For cross-repo impact, also invoke `/cross-repo-impact-review`.
- For CI changes, also invoke `/github-enterprise-ci-review`.

## Guardrails

- Do not soften findings. A `BLOCK` must be resolved before merge.
- Treat `scripts/validate-architecture.sh` output as authoritative; don't second-guess `[LEAK]` flags.
