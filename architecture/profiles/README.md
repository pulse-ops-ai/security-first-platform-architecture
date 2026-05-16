# Profiles

A profile maps the eight control layers from [`../control-layers.md`](../control-layers.md) to concrete technology. Each profile is a self-contained mapping; cross-profile comparisons live in [`../deployment-profiles.md`](../deployment-profiles.md).

This folder describes **what each vendor satisfies and why**. The matching **example configurations** (Docker Compose, Terraform modules, ACLs, tunnel configs) live under [`../../infra/profiles/`](../../infra/profiles/). The two are paired but separately maintained.

## Current profiles

- [`self-hosted-vps.md`](self-hosted-vps.md) — VPS + Docker, Cloudflare Tunnel, Tailscale, Kong CE, Traefik, Keycloak, OpenFGA, Splunk/Grafana
- [`aws-managed.md`](aws-managed.md) — AWS VPC, API Gateway / ALB / NLB, ECS / EKS, Cognito or Auth0 or Keycloak, Verified Permissions or OpenFGA, CloudWatch / Splunk / OTel
- [`hybrid-tailnet.md`](hybrid-tailnet.md) — bridging on-prem and cloud via a private mesh

## Structure

Every profile uses this structure:

1. Summary and when to choose it
2. Layer-by-layer mapping (L1 → L8)
3. Observability mapping
4. Failure modes and degradation behavior
5. Migration paths to and from other profiles
6. Compensating controls for any layer the profile cannot satisfy natively

## Rules

- Profiles are the **only** place vendor names appear at this level of detail.
- Profiles cannot weaken the contracts from [`../control-layers.md`](../control-layers.md). If a vendor cannot meet a contract, document the compensating control.
- Profiles are independent. Changing one profile must not require changing another.
