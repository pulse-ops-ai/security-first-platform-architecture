---
name: repo-healthcheck
description: Verify a repository satisfies the security-first platform repo contract. Use when onboarding a new consuming repo, when CI needs a structural check, or when a PR is suspected of degrading structural compliance.
---

# Repo healthcheck

Confirm that a repository's structural shape matches the [repo contract](../../../standards/repo-contract.md). This is a structural check, not a content review.

## Inputs

- Path to a repository (default: current working directory).

## Procedure

1. Confirm root files exist: `README.md`, `AGENTS.md`, `CLAUDE.md`, `LICENSE`.
2. Confirm required directories exist: `docs/`, `docs/INDEX.md`, `.agents/skills/`, `.agents/skills/INDEX.md`, `openspec/`, `.github/workflows/`.
3. Confirm `.github/workflows/` contains (or references) the three required workflows: `architecture-healthcheck.yml`, `docs-healthcheck.yml`, `skills-healthcheck.yml`.
4. If `.claude/` or `.codex/` exist, confirm they route to `AGENTS.md` rather than duplicating it.
5. Confirm `AGENTS.md` is non-empty and references at least the architecture and team-os entrypoints.
6. Record each finding as `OK` / `MISSING` / `MALFORMED` with the path.

## Output

Return:

- A short report listing each check with `OK` / `MISSING` / `MALFORMED` plus the path.
- A summary count of issues by category.
- An overall `PASS` (no issues) or `FAIL` (any `MISSING` or `MALFORMED`).

Example:

```
[OK]        README.md
[OK]        AGENTS.md
[MISSING]   openspec/
[MALFORMED] .github/workflows/docs-healthcheck.yml — references nonexistent script
```

## Guardrails

- Do not review application logic — use `architecture-review` for that.
- Do not validate OpenSpec proposal content — use `openspec-change-triage`.
- Treat the check as structural only; passing this skill does not imply the repo is architecturally compliant, only that its skeleton is.

## See also

- [`../../../scripts/validate-architecture.sh`](../../../scripts/validate-architecture.sh)
- [`../../../standards/repo-contract.md`](../../../standards/repo-contract.md)
