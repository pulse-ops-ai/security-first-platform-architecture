# AGENTS.md — Universal Agent Contract

> **This is a template.** Copy into a consuming repo and customize the marked sections. Source: [`security-first-platform-architecture/templates/consuming-repo/AGENTS.md`](https://example.invalid/replace-with-real-link).

This file is the **vendor-neutral contract** for every coding agent that operates in this repository: Claude Code, Codex, GitHub Copilot, Cursor, Aider, future agents.

If a vendor-specific file (`CLAUDE.md`, `.codex/`, `.cursorrules`, etc.) ever conflicts with this file, **this file wins**.

---

## What this repo is

<!-- CUSTOMIZE: one-paragraph description of this repo's purpose -->

This repo follows the security-first platform architecture (see the source-of-truth repo `security-first-platform-architecture`). It targets the **<self-hosted-vps | aws-managed | hybrid-tailnet>** deployment profile.

## Operating principles for agents

1. **Architecture alignment.** Follow the eight control layers from `security-first-platform-architecture/architecture/control-layers.md`. Map every new component to a layer.
2. **Agents are clients.** Agents authenticate, authorize, and route like any other client. No back-channels.
3. **OpenSpec for governed changes.** See `openspec/` in this repo and the policy in the architecture repo.
4. **Update indexes when you add/rename files.** `docs/INDEX.md`, `.agents/skills/INDEX.md`.

## Where to find things

| Need | Path |
|---|---|
| Product / operations / decisions | [`docs/INDEX.md`](docs/INDEX.md) |
| Executable skills (canonical) | [`.agents/skills/INDEX.md`](.agents/skills/INDEX.md) |
| Governed changes | [`openspec/`](openspec/) |
| Architecture source of truth | sibling repo `security-first-platform-architecture/` |

## Rules for editing

- Do not duplicate content across files. Cross-reference instead.
- Update the relevant `INDEX.md` when adding, renaming, or removing files.
- Do not put rules into vendor adapter files (`CLAUDE.md`, `.claude/`, `.codex/`) that should apply to all agents — they belong here.

## Rules for new work

- Trivial doc fix → normal PR.
- Architecture-affecting change in this repo → OpenSpec proposal in `openspec/`.
- Cross-repo dependency → dependency record in the architecture repo's `portfolio/dependencies/`.

## Vendor adapters

- [`CLAUDE.md`](CLAUDE.md), `.claude/` — Claude Code routing.
- `.codex/` — Codex routing.
- Adapters route; they never override.
