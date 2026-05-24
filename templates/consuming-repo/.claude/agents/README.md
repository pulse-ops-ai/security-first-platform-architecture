# .claude/agents/

Claude Code sub-agent definitions specific to this consuming repo.

## Conventions

- Each sub-agent is a single file with frontmatter describing its tools, model, and role.
- Sub-agents inherit the universal contract from [`../../AGENTS.md`](../../AGENTS.md).
- Sub-agents that need to enforce a standard or skill should call back to a canonical skill in the **sibling architecture repo** rather than re-implementing the logic. The architecture repo lives next to this one under the workspace parent directory; **from your repo root**, that's at `../security-first-platform-architecture/` and the canonical skills are at `.agents/skills/<name>/SKILL.md` inside that sibling.

## Sub-agents currently defined

_None yet._ Define as the team identifies recurring multi-agent workflows.
