# Security-First Architecture Standard

This standard defines what it means for a consuming repo to **align** with the security-first platform architecture.

It is not a checklist of features. It is a set of structural commitments.

## A consuming repo aligns with the architecture if…

### 1. It identifies its deployment profile

The repo states (in `README.md` or `docs/`) which profile from [`../architecture/profiles/`](../architecture/profiles/) it targets — self-hosted VPS, AWS managed, hybrid tailnet, or a future profile.

### 2. It maps its components to the eight control layers

The repo's architecture documentation maps each component to one or more of the eight layers from [`../architecture/control-layers.md`](../architecture/control-layers.md). Layers it doesn't implement (e.g., L8 if no agents) are listed explicitly with the reason.

### 3. It treats agents as clients

If the repo runs or invokes agents, those agents follow [`../architecture/agent-as-client-model.md`](../architecture/agent-as-client-model.md). No agent runtime gets a privileged shortcut.

### 4. It uses (or compatibly substitutes) the internal identity envelope

If the repo has L6 → L7 internal calls, those calls carry the envelope described in [`../architecture/internal-identity-envelope.md`](../architecture/internal-identity-envelope.md). The envelope format may differ across profiles, but the *claims* and *verification rules* are the same.

### 5. It enforces tenant isolation structurally

Per [`../architecture/multi-tenancy.md`](../architecture/multi-tenancy.md), tenant isolation is not a single application-layer filter. It is at least two of: identity, authorization, data partitioning.

### 6. It emits the required observability signals

Every component emits logs, metrics, and (sampled) traces per [`../architecture/observability.md`](../architecture/observability.md). Audit-class events go to the audit sink, not just operational logs.

### 7. It documents trust zones

The repo's docs identify the zones from [`../architecture/security-boundaries.md`](../architecture/security-boundaries.md) and which components live in which zone.

## What "alignment" is not

- It is not a binary state attested by a checkmark. It is an ongoing commitment.
- It is not a guarantee against vulnerabilities — it is a guarantee that the *structure* makes vulnerabilities recoverable.
- It is not enforced by automated tests alone. The `security-control-review` skill ([`../.agents/skills/security-control-review/SKILL.md`](../.agents/skills/security-control-review/SKILL.md)) supports human review.

## Drift

A repo drifts out of alignment when:

- A component bypasses a layer (e.g., a back-channel that skips L4).
- An agent runtime is treated as an insider.
- Tenant isolation is reduced to a single application filter.
- Observability is silenced (sampled to zero, dropped before shipping) for security-relevant events.

Drift is fixed by an OpenSpec proposal in the consuming repo, not silently.
