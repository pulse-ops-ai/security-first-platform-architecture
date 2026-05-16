---
argument-hint: "[optional: repo path, default current dir]"
---

# GitHub Enterprise CI review

Run the `github-enterprise-ci-review` skill against the supplied repo path. Canonical procedure: [`../../.agents/skills/github-enterprise-ci-review/SKILL.md`](../../.agents/skills/github-enterprise-ci-review/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. Resolve the repo path (default `.`).
2. Confirm `.github/workflows/` exists and contains the three required workflows (`architecture-healthcheck.yml`, `docs-healthcheck.yml`, `skills-healthcheck.yml`) directly or via reusable workflow reference.
3. For each `.yml` in `.github/workflows/`:
   - Confirm triggers include `pull_request` and `push: main`.
   - Validate job IDs against `^[a-z][a-z0-9-]*$` and flag renames in the diff (branch protection breakage risk).
4. Confirm `CODEOWNERS` covers `/architecture/`, `/team-os/`, `/standards/`, `/templates/`, `/portfolio/`, `/infra/`, `/.github/`, `/scripts/`, `/AGENTS.md`, `/SECURITY.md`.
5. Check action pinning (SHA or vN tag) and OIDC for any deploy workflow.
6. Return the report shape defined in the skill with `PASS` / `WARN` / `BLOCK` per area.

## Guardrails

- Missing required workflow → `BLOCK`.
- Long-lived cloud credentials → `WARN` (migrate to OIDC).
- Renamed job IDs in the diff → `WARN` (branch protection may silently break).
- This command does NOT edit workflows; report only.
