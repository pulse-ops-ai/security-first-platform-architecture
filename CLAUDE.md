# CLAUDE.md — Claude Code Adapter

You are working in **`security-first-platform-architecture`** — the reusable, implementation-neutral security-first platform architecture and TeamOS adoption kit.

> This file is an **adapter**. The source of truth is [`AGENTS.md`](AGENTS.md) and the indexes it points to. If anything here conflicts with `AGENTS.md`, follow `AGENTS.md`.

## Read first

1. [`AGENTS.md`](AGENTS.md) — universal agent contract
2. The index for whatever folder you are about to edit:
   - [`architecture/INDEX.md`](architecture/INDEX.md)
   - [`team-os/INDEX.md`](team-os/INDEX.md)
   - [`standards/INDEX.md`](standards/INDEX.md)
   - [`docs/INDEX.md`](docs/INDEX.md)
   - [`portfolio/INDEX.md`](portfolio/INDEX.md)
   - [`.agents/skills/INDEX.md`](.agents/skills/INDEX.md)

## Don't

- Don't read every file. Use indexes.
- Don't scaffold application code, runtimes, services, frontends, or backends. This is the architecture & TeamOS layer.
- Don't name the architecture after a vendor. Vendor names belong only in [`architecture/profiles/`](architecture/profiles/).
- Don't put rules into `CLAUDE.md` or `.claude/` that contradict `AGENTS.md`. Update `AGENTS.md` instead.

## When in doubt

- Ask. Don't guess at architectural intent.
- Prefer cross-references over copying content between files.
- Update the relevant `INDEX.md` when you add or rename files.

## Skills

Canonical, vendor-neutral skills live in [`.agents/skills/`](.agents/skills/). The [`.claude/skills/`](.claude/skills/) directory is for Claude-specific shims only, and [`.claude/commands/`](.claude/commands/) holds slash commands that surface those skills. Browse [`.agents/skills/INDEX.md`](.agents/skills/INDEX.md) first.
