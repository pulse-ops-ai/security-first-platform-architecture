# Hybrid Tailnet — Reference Infrastructure

Reference assets for the hybrid-tailnet profile described in [`../../../architecture/profiles/hybrid-tailnet.md`](../../../architecture/profiles/hybrid-tailnet.md).

> Reference only. The hybrid profile is **AWS-managed plus a private mesh layer**. For the AWS pieces, use [`../aws-managed/`](../aws-managed/). This directory only contains the deltas: the tailnet ACL and the Cloudflare tunnel for the on-prem side.

## What changes vs AWS-managed

| Layer | Delta from `aws-managed/` |
|---|---|
| L1 — Network reachability | Add a private mesh (Tailscale or equivalent). Subnet routers advertise on-prem CIDRs into the tailnet. Public end-user traffic still enters via the AWS edge — the tailnet is for east-west and operator traffic only. |
| L2–L8 | Unchanged. The tailnet is a network path, **not** an identity. |

## Files

- [`tailscale/acl.example.hujson`](tailscale/acl.example.hujson) — Tailscale ACL for the hybrid topology (AWS-side nodes + on-prem nodes + operator devices).
- [`cloudflare/tunnel.example.yaml`](cloudflare/tunnel.example.yaml) — Cloudflare tunnel config for on-prem-hosted services that need to be reachable through the AWS edge.

## Hard rule

The tailnet is **never** an authentication signal for end-user traffic. Even mesh-internal calls that hit the platform terminate at the L2 edge (API Gateway / ALB) and re-authenticate per the [agent-as-client model](../../../architecture/agent-as-client-model.md) and [security boundaries](../../../architecture/security-boundaries.md).

## How to consume

1. Take the `aws-managed/` reference as the base for the cloud side.
2. Copy this directory into your solution-infra repo alongside it.
3. Replace tag and group placeholders in `acl.example.hujson` with real Tailscale tags backed by your SSO.
4. Replace `__TUNNEL_ID__`, `__DOMAIN__`, and origin URLs in `tunnel.example.yaml`.
5. Never commit the Tailscale auth keys or Cloudflare tunnel credentials.
