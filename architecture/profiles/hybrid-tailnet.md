# Profile: Hybrid Tailnet

> Reference Tailscale ACL and Cloudflare tunnel examples for this profile live under [`../../infra/profiles/hybrid-tailnet/`](../../infra/profiles/hybrid-tailnet/). The cloud side reuses [`../../infra/profiles/aws-managed/`](../../infra/profiles/aws-managed/).

## When to choose this profile

- Compute is in AWS (or another cloud) but data, devices, or partner systems live on-prem.
- A private mesh is preferable to public internet hops for east-west traffic between cloud and on-prem.
- A team wants the AWS managed profile **plus** authenticated mesh access to non-cloud assets.

This profile is **AWS-managed + a private mesh layer**, not a third independent stack. Most of the architecture comes from [`aws-managed.md`](aws-managed.md). This document only highlights what is different.

## Layer-by-layer deltas

### L1 — Network reachability

- **Tailscale** (or equivalent private mesh: Twingate, Zerotier, AWS Verified Access in mesh mode) provides authenticated mesh connectivity between cloud VPCs, on-prem networks, operator devices, and select services.
- **Tailscale subnet routers** advertise on-prem CIDRs into the tailnet; ACLs constrain which nodes can reach what.
- The public edge (L2) is **still** the only way external clients enter the system. The tailnet is for east-west and operator traffic, not for end-user access.

**Contract.** Tailnet membership is **not** an identity for end-user requests. Even mesh-internal traffic that hits the platform terminates at the L2 gateway.

### L2 — Edge gateway / routing

Unchanged from AWS-managed: API Gateway or ALB/NLB. The tailnet may *carry* the connection, but the gateway still terminates it.

### L3 — Identity

Unchanged. Tailscale identity (SSO-backed) is fine for **operator** and **node** access but is **separate** from L3 user/service/agent identity. The two must not be conflated.

### L4 — Authorization

Unchanged. Tailscale ACLs are network-level; they do not replace L4.

### L5 — Operational guardrails

Unchanged.

### L6 — Orchestrator / BFF

Unchanged. The orchestrator does not look at the tailnet — it looks at the envelope.

### L7 — Service-level enforcement

Unchanged. Service code does not trust the tailnet.

### L8 — Semantic / agent reasoning

- Agents that run on-prem (e.g., a developer's machine running Claude Code, a workstation running a workflow agent) reach the platform through the tailnet **only** as a network path. Authentication, authorization, and envelope rules from [`../agent-as-client-model.md`](../agent-as-client-model.md) still apply.

## Observability

- Tailscale logs (node connect/disconnect, ACL hits) ship to the central observability pipeline alongside the AWS-managed signals.
- Audit log captures the tailnet identity **and** the L3 principal where they overlap (e.g., for operator actions).

## Failure modes

| Failure | Behavior |
|---|---|
| Tailnet coordination plane outage | Existing sessions persist; new joins fail. End-user traffic via the public edge is unaffected. |
| On-prem subnet router outage | On-prem-only resources unreachable; cloud-only paths unaffected. |

## Migration paths

- **From self-hosted VPS:** add a tailnet, migrate cloud-side to AWS-managed; the tailnet is the bridge.
- **From AWS-managed:** add a tailnet when on-prem connectivity becomes necessary.

## Compensating controls

- **Mesh-as-identity is forbidden.** Tooling and code must treat tailnet membership as a network signal, never as an authentication or authorization signal.
- **Operator-vs-service separation.** Tailnet ACLs differentiate operator nodes from workload nodes. Workload-to-workload paths over the tailnet are kept minimal.
