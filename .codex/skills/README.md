# .codex/skills/

Codex-specific **shims** to skills. The canonical skills live in [`../../.agents/skills/`](../../.agents/skills/).

A shim in this folder might:

- Expose a canonical skill under a Codex-friendly name.
- Provide Codex-specific invocation hints.
- Reference the canonical `SKILL.md` rather than duplicating it.

## Rules

- **No skill content here.** Procedure, steps, and outputs live in the canonical `.agents/skills/<name>/SKILL.md`.
- **No conflicts.** A shim must not redefine the skill — only adapt it.

## Skills currently shimmed

_None yet._
