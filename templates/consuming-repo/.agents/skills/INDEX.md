# .agents/skills/ — Catalog

> **Template.** Replace with the actual skill catalog when you copy into a consuming repo.

Canonical, vendor-neutral executable skills for this repo. Vendor-specific shims live in `.claude/skills/` and `.codex/skills/` and reference these.

| Skill | Purpose |
|---|---|
| _none yet_ | _populate as skills are added_ |

## Conventions

- Skill folder names are kebab-case.
- Every skill folder has exactly one `SKILL.md`.
- Each `SKILL.md` begins with YAML frontmatter (`name`, `description`).
- Required body sections: `## Procedure`, `## Output`. Recommended: `## Inputs`, `## Guardrails`, `## See also`.

## Standard reference

See the architecture repo's `standards/agent-instructions-standard.md` for the full SKILL.md structure.
