# .claude/skills/

Claude-specific **shims** to skills. Canonical skills live in the architecture repo at `.agents/skills/`; this directory only carries Claude-specific invocation hints when one is needed.

## Pattern

For most vendor-neutral skills, the slash command (in `../commands/`) is the Claude adapter — no shim is needed here. Add a shim only when Claude needs invocation semantics that differ from the canonical procedure (e.g., `$ARGUMENTS` parsing, tool hints, output formatting).

## Rules

- **No skill content here.** Procedure, steps, and outputs live in the canonical `.agents/skills/<name>/SKILL.md` in the architecture repo.
- A shim must **route**, not duplicate. Reference the canonical SKILL.md path.

## Currently shimmed

_None yet._ Add as Claude-specific invocations are needed.
