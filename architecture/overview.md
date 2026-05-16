# Architecture Overview

## What this architecture is

A **security-first platform architecture**: a reusable model for building enterprise systems where every request — human, service, or agent — is authenticated, authorized, observable, and routed through layered controls that can be implemented on self-hosted infrastructure today and managed cloud services tomorrow.

It is deliberately **implementation-neutral**. The same architecture supports:

- a self-hosted VPS deployment
- a cloud-managed deployment
- a hybrid arrangement bridging on-prem and cloud via a private mesh
- future cloud-provider profiles

Concrete vendor mappings live in [`profiles/`](profiles/). The architecture is the constant. Vendors are variables.

## What problem it solves

Most platforms collapse concerns: a single gateway does authn, authz, routing, observability, and rate-limiting; a single service does business logic, tenant isolation, and audit. When the company outgrows one vendor or one deployment model, the platform must be rebuilt.

This architecture solves that by **separating control concerns into eight independent layers** (see [`control-layers.md`](control-layers.md)). Each layer has a clear contract. Each layer can be replaced with a different implementation without changing the layers above or below it.

## Who it is for

- Engineering teams operating multiple solution products in a shared workspace (`trupryce`, `findevil`, `levelup-platform`, etc.) who need a shared architectural language.
- Platform teams who need to support both self-hosted and cloud-managed deployments simultaneously.
- Teams adopting agentic systems who need agents to be treated as authenticated clients rather than privileged insiders.
- Teams using coding agents who need a TeamOS that gives those agents the right context, regardless of which agent or tool is in use.

## What it is not

- Not a runtime, framework, or library.
- Not a vendor stack.
- Not a substitute for product-specific design.

It is a **reference model** plus a **TeamOS** that consuming repos adopt.

## How to read the rest of this folder

1. [`principles.md`](principles.md) — non-negotiable design principles
2. [`control-layers.md`](control-layers.md) — the eight-layer model
3. [`security-boundaries.md`](security-boundaries.md) — trust zones
4. [`identity-and-authorization.md`](identity-and-authorization.md) — identity flow
5. [`agent-as-client-model.md`](agent-as-client-model.md) — how agents fit in
6. [`profiles/`](profiles/) — concrete vendor mappings
