# CLAUDE.md — Claude Code Adapter

> **This is a template.** Copy into a consuming repo. Keep it short.

You are working in **<REPO_NAME>**, a consuming repo of the security-first platform architecture.

This file is an **adapter**. The source of truth is [`AGENTS.md`](AGENTS.md). If anything here conflicts with `AGENTS.md`, follow `AGENTS.md`.

## Read first

1. [`AGENTS.md`](AGENTS.md)
2. [`docs/INDEX.md`](docs/INDEX.md)
3. [`.agents/skills/INDEX.md`](.agents/skills/INDEX.md)
4. The sibling architecture repo if needed: `../security-first-platform-architecture/`

## Don't

- Don't read every file. Use indexes.
- Don't bypass the gateway when reasoning about agent-initiated calls. Agents are clients.
- Don't put rules in this file that should apply to all agents — they go in `AGENTS.md`.

## When in doubt

- Ask. Don't guess at architectural intent.
- Prefer cross-references over copying content.
- Update the relevant `INDEX.md` when you add or rename files.
