# docs/decisions/ — Index

Architecture Decision Records (ADRs) for this repo. An ADR captures **why** a decision was made, not just **what** the decision is.

## Conventions

- ADRs are named `ADR-NNNN-short-title.md` where `NNNN` is a zero-padded sequence number.
- New ADRs use [`../../templates/adr/ADR-template.md`](../../templates/adr/ADR-template.md).
- An ADR is **immutable** once accepted. Reverse a decision by writing a new ADR that supersedes the old one.

## When to write an ADR

- A trade-off was real and another reasonable team would have chosen differently.
- The decision shapes the architecture, standards, or TeamOS materially.
- The decision will be questioned in 6+ months and "see ADR-N" is the right answer.

## ADRs vs OpenSpec

- **OpenSpec** is the process for *making* governed changes (proposal, alternatives, plan, approval).
- **ADRs** are the persistent *record* of decisions and their rationale.
- Many Tier 3 OpenSpec proposals will produce an ADR. Many ADRs (especially historical ones) may not have an OpenSpec proposal behind them.

## ADRs

### Foundational (retroactive capture of decisions embedded in PR #1)

- [`ADR-0001-adopt-eight-layer-control-model.md`](ADR-0001-adopt-eight-layer-control-model.md) — Separate the platform into eight control layers (L1 network → L8 semantic). Profiles map vendors to layers; the layers are constant.
- [`ADR-0002-agents-are-clients-not-insiders.md`](ADR-0002-agents-are-clients-not-insiders.md) — Every agent authenticates, authorizes, and routes through the same controls as any other client. No privileged back-channel.
- [`ADR-0003-internal-identity-envelope-as-z4-trust.md`](ADR-0003-internal-identity-envelope-as-z4-trust.md) — A short-lived signed envelope issued by L6 is the canonical L6→L7 trust mechanism inside Z4. Format is vendor-neutral; claims and verification rules are uniform.
