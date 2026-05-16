# .claude/commands/

Claude Code slash commands specific to this repo.

## Conventions

- One markdown file per command (`/my-command` → `my-command.md`).
- Each command is short and points to the canonical skill in [`../../.agents/skills/`](../../.agents/skills/) or to the document it operates on.
- Commands do not re-implement skills; they invoke them.

## Commands currently defined

- `/pull-from-notion` — see [`pull-from-notion.md`](pull-from-notion.md); invokes [`../../.agents/skills/pull-from-notion/SKILL.md`](../../.agents/skills/pull-from-notion/SKILL.md)
- `/push-to-notion` — see [`push-to-notion.md`](push-to-notion.md); invokes [`../../.agents/skills/push-to-notion/SKILL.md`](../../.agents/skills/push-to-notion/SKILL.md)
