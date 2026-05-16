# AGENTS.md — Universal Agent Contract

This file is the **vendor-neutral contract** for every coding agent that operates in this repository: Claude Code, Codex, GitHub Copilot, Cursor, Aider, future agents.

If a vendor-specific file (`CLAUDE.md`, `.codex/`, `.cursorrules`, etc.) ever conflicts with this file, **this file wins**.

---

## What this repo is

This is the **security-first platform architecture and TeamOS adoption kit**. It is implementation-neutral. It does not contain application code or runtimes. See [`README.md`](README.md).

## Operating principles for agents

1. **Context is architecture.** Read the index before reading content. Indexes (`*/INDEX.md`) are the navigation spine.
2. **Structure is speed.** Do not invent new top-level folders. Use the structure defined in [`standards/repo-contract.md`](standards/repo-contract.md).
3. **Implementation-neutral.** Never name the architecture after a vendor (Kong, Tailscale, AWS, Cloudflare, etc.). Vendor names belong only in [`architecture/profiles/`](architecture/profiles/).
4. **Agents are clients.** When reasoning about runtime behavior, treat agents as external callers that must authenticate, authorize, and traverse the gateway like any other client. See [`architecture/agent-as-client-model.md`](architecture/agent-as-client-model.md).
5. **OpenSpec for governed changes.** Architecture, standards, and cross-repo contracts require an OpenSpec proposal — see [`team-os/openspec-policy.md`](team-os/openspec-policy.md).

## Where to find things

| Need | Path |
|---|---|
| Architecture concepts | [`architecture/INDEX.md`](architecture/INDEX.md) |
| Deployment profile mapping | [`architecture/profiles/`](architecture/profiles/) |
| **Foundational decisions (trade-off records)** | [`docs/decisions/INDEX.md`](docs/decisions/INDEX.md) |
| Product framing (promises, non-promises, owners, adoption path) | [`docs/product/INDEX.md`](docs/product/INDEX.md) |
| Reference infrastructure (example configs, modules, policies — **no live secrets**) | [`infra/`](infra/) |
| How the team operates | [`team-os/INDEX.md`](team-os/INDEX.md) |
| Repo and doc standards | [`standards/INDEX.md`](standards/INDEX.md) |
| Operational runbooks | [`docs/operations/INDEX.md`](docs/operations/INDEX.md) |
| Cross-repo epics & dependencies | [`portfolio/INDEX.md`](portfolio/INDEX.md) |
| Executable skills (canonical) | [`.agents/skills/INDEX.md`](.agents/skills/INDEX.md) |
| Templates (consuming repo, ADR, OpenSpec, dependency) | [`templates/`](templates/) |

## Rules for editing

- **Do not duplicate content** across files. Cross-reference instead.
- **Update the relevant `INDEX.md`** when adding, renaming, or removing files in that folder.
- **Do not put vendor-specific guidance** in `architecture/*.md` (excluding `profiles/`). Vendor specifics live in `architecture/profiles/*` (the *what and why*) and `infra/profiles/*` (the *example configs*).
- **Do not edit `.claude/` or `.codex/` instead of `AGENTS.md`.** Vendor adapters route to the universal contract; they are not the contract.
- **Never scaffold application code, runtimes, frontends, or backends in this repo.** This is the architecture & TeamOS layer.
- **Never commit live secrets, real account IDs, tenant credentials, or production tfstate** anywhere — especially not under `infra/`. See [`infra/README.md`](infra/README.md) for the rules.

## Rules for new work

- Trivial documentation fix → normal PR.
- New architecture concept, new standard, or change to cross-repo contract → **OpenSpec proposal** ([`templates/openspec/proposal-template.md`](templates/openspec/proposal-template.md)).
- Architectural decision with trade-offs → **ADR** ([`templates/adr/ADR-template.md`](templates/adr/ADR-template.md)) in [`docs/decisions/`](docs/decisions/).
- Cross-repo dependency → **Dependency record** ([`templates/dependency-record/dependency-template.md`](templates/dependency-record/dependency-template.md)) in [`portfolio/dependencies/`](portfolio/dependencies/).

## Vendor adapters

| Agent | Adapter directory | Purpose |
|---|---|---|
| Claude Code | [`CLAUDE.md`](CLAUDE.md), [`.claude/`](.claude/) | route Claude to the right indexes & skills |
| Codex | [`.codex/`](.codex/) | route Codex to the right indexes & skills |
| GitHub Copilot / Cursor / Aider | this file (`AGENTS.md`) | universal contract; no adapter needed |

Adapters **route**; they never **override**. The source of truth is `AGENTS.md` + the indexes.
