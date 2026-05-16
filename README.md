# security-first-platform-architecture

A **reusable, implementation-neutral security-first platform architecture** and a **TeamOS adoption kit** for the enterprise.

This repository is **not an application**. It is the source of truth for:

- the reference architecture (control layers, identity, authorization, observability, agent-as-client)
- the TeamOS (how teams structure repos, context, and governance so coding agents work well)
- the standards every consuming repo must adopt (`AGENTS.md`, `CLAUDE.md`, `docs/INDEX.md`, `.agents/skills/INDEX.md`, `openspec/`, `.github/workflows/`)
- the templates and skills that let solution repos consume the architecture quickly
- reference infrastructure ([`infra/`](infra/)) — example configs, reusable modules, and policy assets per profile (no live deployment, no secrets)

## Motto

> Context is architecture. Structure is speed. Update the operating system as the team learns.

## What this repo is *not*

- Not an application.
- Not a runtime.
- Not tied to Cloudflare, Tailscale, Kong, Traefik, Keycloak, OpenFGA, AWS, Azure, or GCP.
- Not a fork of any vendor reference architecture.

It is the layer above all of those — the architecture and operating model that survives when the underlying technology changes.

## Core thesis

A security-first platform separates **eight control layers** (see [`architecture/control-layers.md`](architecture/control-layers.md)):

1. network reachability
2. edge gateway / routing
3. identity
4. authorization
5. operational guardrails
6. orchestrator / BFF
7. service-level enforcement
8. semantic / agent reasoning

Every implementation profile (self-hosted VPS, AWS-managed, hybrid tailnet, future Azure/GCP) maps concrete technology to those layers. The architecture is the constant; the technology is the variable.

For agentic systems: **agents are clients, not insiders**. They authenticate, authorize, and traverse the same gateway and policy chain as any other caller. See [`architecture/agent-as-client-model.md`](architecture/agent-as-client-model.md).

## Workspace model

This repo is the source of truth for a multi-repo workspace cloned side-by-side:

```
~/work/security-first-platform/
  security-first-platform-architecture/   # this repo — the architecture & TeamOS
  trupryce/                                # solution repo (consumer)
  findevil/                                # solution repo (consumer)
  levelup-platform/                        # solution repo (consumer)
  splunk-agentic-ops/                      # solution repo (consumer)
```

Consuming repos are expected to:

1. follow the **repo contract** in [`standards/repo-contract.md`](standards/repo-contract.md)
2. include `AGENTS.md`, `CLAUDE.md`, `docs/INDEX.md`, `.agents/skills/INDEX.md`, `openspec/`, `.github/workflows/`
3. record cross-repo dependencies using [`templates/dependency-record/`](templates/dependency-record/)
4. use [`templates/consuming-repo/`](templates/consuming-repo/) as a starting point

See [`team-os/workspace-model.md`](team-os/workspace-model.md) and [`team-os/cross-repo-governance.md`](team-os/cross-repo-governance.md).

## How to navigate this repo

| If you want to… | Start at |
|---|---|
| Understand the architecture | [`architecture/INDEX.md`](architecture/INDEX.md) |
| Map architecture to AWS or self-hosted | [`architecture/profiles/`](architecture/profiles/) |
| See reference configurations for a profile | [`infra/`](infra/) |
| Understand how the team operates | [`team-os/INDEX.md`](team-os/INDEX.md) |
| Adopt the architecture in your repo | [`standards/repo-contract.md`](standards/repo-contract.md) + [`templates/consuming-repo/`](templates/consuming-repo/) |
| Find an agent skill to run | [`.agents/skills/INDEX.md`](.agents/skills/INDEX.md) |
| Brief a coding agent (any vendor) | [`AGENTS.md`](AGENTS.md) |
| Brief Claude Code specifically | [`CLAUDE.md`](CLAUDE.md) |

## Agents

- [`AGENTS.md`](AGENTS.md) is the **universal** contract for Claude Code, Codex, GitHub Copilot, and future agents.
- [`CLAUDE.md`](CLAUDE.md) and [`.claude/`](.claude/) are **adapters** that route Claude to the universal contract.
- [`.codex/`](.codex/) is the Codex adapter. Same pattern.
- The source of truth is always `AGENTS.md` plus the indexes — adapters never contradict it.

## Governance

- Formal changes to architecture, standards, or cross-repo contracts go through **OpenSpec** — see [`team-os/openspec-policy.md`](team-os/openspec-policy.md).
- CI/CD on **GitHub Enterprise** — see [`team-os/github-enterprise-ci.md`](team-os/github-enterprise-ci.md).
- Decisions are captured as ADRs in [`docs/decisions/`](docs/decisions/) using [`templates/adr/ADR-template.md`](templates/adr/ADR-template.md).

## License

See [`LICENSE`](LICENSE).
