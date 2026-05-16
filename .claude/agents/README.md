# .claude/agents/

Claude Code sub-agent definitions used in this repo. Sub-agents are specialized agents launched from a primary agent for parallel or focused work.

## Conventions

- Each sub-agent is a single file with frontmatter describing its tools, model, and role.
- Sub-agents inherit the universal contract from [`../../AGENTS.md`](../../AGENTS.md).
- Sub-agents that need to enforce a standard or skill should call back to canonical skills in [`../../.agents/skills/`](../../.agents/skills/) rather than re-implementing the logic.

## Sub-agents currently defined

_None yet._ Define as the team identifies recurring multi-agent workflows.
