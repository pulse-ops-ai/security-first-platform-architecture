# .claude/agents/

Claude Code sub-agent definitions specific to this consuming repo.

## Conventions

- Each sub-agent is a single file with frontmatter describing its tools, model, and role.
- Sub-agents inherit the universal contract from [`../../AGENTS.md`](../../AGENTS.md).
- Sub-agents that need to enforce a standard or skill should call back to a canonical skill in the architecture repo (`../security-first-platform-architecture/.agents/skills/`) rather than re-implementing the logic.

## Sub-agents currently defined

_None yet._ Define as the team identifies recurring multi-agent workflows.
