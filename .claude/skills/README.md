# .claude/skills/

Claude-specific **shims** to skills. The canonical skills live in [`../../.agents/skills/`](../../.agents/skills/).

A shim in this folder might:

- Expose a canonical skill under a Claude-friendly name or slash command (see also [`../commands/`](../commands/)).
- Provide Claude-specific invocation hints (which tools to use, how to format output for Claude Code).
- Reference the canonical `SKILL.md` rather than duplicating it.

## Rules

- **No skill content here.** Procedure, steps, and outputs live in the canonical `.agents/skills/<name>/SKILL.md`.
- **No conflicts.** A shim must not redefine the skill — only adapt it.
- If a Claude-specific behavior is broadly useful, propose moving it into the canonical skill (Tier 1 OpenSpec).

## Skills currently shimmed

- `pull-from-notion/` — Claude shim for [`../../.agents/skills/pull-from-notion/SKILL.md`](../../.agents/skills/pull-from-notion/SKILL.md)
- `push-to-notion/` — Claude shim for [`../../.agents/skills/push-to-notion/SKILL.md`](../../.agents/skills/push-to-notion/SKILL.md)
