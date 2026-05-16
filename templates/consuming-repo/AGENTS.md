# AGENTS.md — Universal Agent Contract

> **This is a template.** Copy into a consuming repo and customize the marked sections. Source: `security-first-platform-architecture/templates/consuming-repo/AGENTS.md`.

This file is the **vendor-neutral contract** for every coding agent that operates in this repository — Claude Code, Codex, GitHub Copilot, Cursor, Aider, and any future agent.

If a vendor-specific adapter file (`CLAUDE.md`, `.claude/`, `.codex/`, `.github/copilot-instructions.md`, `.cursorrules`, etc.) ever conflicts with this file, **this file wins**.

A consuming repo only ships the adapter files for the tools its team uses. `AGENTS.md` is universal; everything else is opt-in.

---

## What this repo is

<!-- CUSTOMIZE: one-paragraph description of this repo's purpose -->

This repo follows the security-first platform architecture. The pinned architecture-repo ref and the deployment profile are recorded in [`security-first-adoption.md`](security-first-adoption.md).

## Operating principles for agents

1. **Architecture alignment.** Follow the eight control layers from the architecture repo's `architecture/control-layers.md`. Map every new component to a layer.
2. **Agents are clients.** Agents authenticate, authorize, and route like any other client. No back-channels.
3. **OpenSpec for governed changes.** See `openspec/` in this repo and the policy in the architecture repo. Tier 2/3 changes always require an OpenSpec proposal.
4. **Adoption record is the source of truth for "what version of the architecture do we follow."** When in doubt, read `security-first-adoption.md` before assuming the latest architecture rules apply.
5. **Update indexes when you add/rename files.** Especially `docs/INDEX.md` and (if present) `.agents/skills/INDEX.md`.

## Where to find things

| Need | Path |
|---|---|
| Which architecture-repo ref this repo tracks | [`security-first-adoption.md`](security-first-adoption.md) |
| Product / operations / decisions docs | [`docs/INDEX.md`](docs/INDEX.md) |
| Executable skills (if this repo ships any) | [`.agents/skills/INDEX.md`](.agents/skills/INDEX.md) — present only if this repo exposes local skills |
| Governed changes | [`openspec/`](openspec/) |
| Architecture source of truth | sibling repo `security-first-platform-architecture/` (cloned at the ref recorded in the adoption record) |

## Rules for editing

- Do not duplicate content across files. Cross-reference instead.
- Update the relevant `INDEX.md` when adding, renaming, or removing files.
- Do not put rules into vendor adapter files (`CLAUDE.md`, `.claude/`, `.codex/`, `.github/copilot-instructions.md`, etc.) that should apply to all agents — they belong **here** so every tool sees them.
- Do not change `security-first-adoption.md`'s `architecture_ref` without an OpenSpec proposal in this repo and a dependency record in the architecture repo's `portfolio/dependencies/`.

## Rules for new work

- Trivial doc fix → normal PR.
- Anything that touches a repo contract, standard, template, skill, CI gate, or security boundary in this repo → **OpenSpec proposal in `openspec/`** (see the architecture repo's `team-os/openspec-policy.md` for the tier rules).
- Cross-repo dependency → dependency record in the architecture repo's `portfolio/dependencies/`, and a corresponding entry under `cross_repo_dependencies:` in this repo's `security-first-adoption.md`.

## Vendor adapters in this repo

<!-- CUSTOMIZE: list only the adapters this repo actually uses. Delete rows for tools the team does not use. -->

- [`CLAUDE.md`](CLAUDE.md), `.claude/` — Claude Code routing (delete if not using Claude).
- `.codex/` — Codex routing (delete if not using Codex).
- `.github/copilot-instructions.md` — GitHub Copilot routing (delete if not using Copilot).
- `.cursorrules` — Cursor routing (delete if not using Cursor).

Adapters route; they never override. The source of truth is `AGENTS.md` plus the indexes.
