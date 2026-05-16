---
argument-hint: "[optional: repo path, default current dir]"
---

# Repo healthcheck

Run the `repo-healthcheck` skill against the supplied repo. Canonical procedure: [`../../.agents/skills/repo-healthcheck/SKILL.md`](../../.agents/skills/repo-healthcheck/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. Resolve the repo path (default `.`).
2. Check the Universal Floor per `standards/repo-contract.md`:
   - Root files: `README.md`, `AGENTS.md`, `LICENSE`, `security-first-adoption.md`.
   - Required dirs: `docs/`, `docs/INDEX.md`.
   - Conditional: `openspec/README.md` if the repo uses OpenSpec; `.github/workflows/` if the repo owns its CI.
3. Check Vendor-Specific Adapters present only if the corresponding tool is in use (per the repo's own `agent_adapters_in_use:` block in `security-first-adoption.md`).
4. If `.claude/`, `.codex/`, `.github/copilot-instructions.md`, or `.cursorrules` exist, confirm they route to `AGENTS.md` rather than duplicating it.
5. Confirm `AGENTS.md` is non-empty and references at least the architecture and team-os entrypoints.
6. Confirm `security-first-adoption.md` has all required frontmatter fields populated.
7. Report each finding as `OK` / `MISSING` / `MALFORMED` with the path; summarize.

## Guardrails

- Treat this as a STRUCTURAL check only. Passing this skill does not imply architectural compliance — for that, use `/architecture-review`.
- Adapter directories that exist but route incorrectly are `BLOCK` findings.
- Missing optional adapter files are not findings; they just mean the repo doesn't use that tool.
