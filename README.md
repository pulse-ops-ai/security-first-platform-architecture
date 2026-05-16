# security-first-platform-architecture

A **reusable, implementation-neutral security-first platform architecture** and a **TeamOS adoption kit** for the enterprise.

> Context is architecture. Structure is speed. Update the operating system as the team learns.

This repository is **not** an application, runtime, or vendor stack. It is the source-of-truth contract that consuming repos (`trupryce`, `findevil`, `levelup-platform`, …) adopt by reference.

## Start here — by what you came for

| If you are… | Start at |
|---|---|
| A stakeholder, product owner, sponsor, or auditor asking *what does this repo promise* | [`docs/product/INDEX.md`](docs/product/INDEX.md) |
| An engineer adopting, extending, or reviewing the architecture | [`architecture/INDEX.md`](architecture/INDEX.md) |
| An operator running this repo's CI or onboarding a consumer | [`docs/operations/INDEX.md`](docs/operations/INDEX.md) |
| Reviewing the *why* behind foundational decisions | [`docs/decisions/INDEX.md`](docs/decisions/INDEX.md) |
| A coding agent (Claude Code, Codex, Copilot, Cursor, …) | [`AGENTS.md`](AGENTS.md) |
| Reporting a security issue | [`SECURITY.md`](SECURITY.md) |

Each of these is an authoritative entry point. The audience-specific surface owns the detail; this README does not duplicate it.

## What this repo is, briefly

A **security-first platform** separates control concerns into **eight layers** (network → edge → identity → authorization → operational guardrails → orchestrator → service → semantic). The architecture is constant across deployment profiles (self-hosted VPS, AWS-managed, hybrid tailnet, future Azure/GCP); only the vendor mappings vary. For agentic systems: **agents are clients, not insiders**. They authenticate, authorize, and route through the same controls as any other caller.

The repo ships the architecture, the standards, the templates, the agent-skill catalog, the OpenSpec governance machinery, and the reference infrastructure that consuming repos adopt. The foundational decisions are captured as ADRs in [`docs/decisions/`](docs/decisions/).

## License

See [`LICENSE`](LICENSE).
