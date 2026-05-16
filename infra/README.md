# infra/ — Reference Infrastructure

This directory contains **reference infrastructure**: example configurations, reusable modules, and policy assets that illustrate how the [eight-layer architecture](../architecture/control-layers.md) can be implemented per [deployment profile](../architecture/profiles/).

It is **not** the source of truth for any live deployment.

## Hard rules

| Rule | Why |
|---|---|
| **No live secrets.** Tokens, passwords, real client IDs, private keys, customer data — none of it lands here. | This repo is the architecture & TeamOS layer. Secrets belong in secret managers, scoped to live infra repos. |
| **No production tfstate.** Terraform examples here use no remote backend (or a placeholder commented out). Real state lives in the deploying repo's backend. | Sharing state across repos couples lifecycles and creates a destroy-everything blast radius. |
| **No tenant-specific deployment credentials.** No tenant subdomains, account IDs, or per-customer config baked into example files. | Tenant config is owned by the solution repo deploying for that tenant. |
| **Every file is example / template / module / validation asset.** Filenames carry `.example.` where the file would otherwise look canonical (e.g., `docker-compose.example.yml`, `terraform.tfvars.example`). | Makes it obvious at a glance that the file is reference, not deployable. |
| **Live deployment belongs in a separate repo.** When a solution needs to actually deploy, create or consume a sibling implementation repo such as `levelup-platform-infra`, `trupryce-infra`, etc. | Keeps architecture decoupled from operator concerns and keeps blast radius local to each consumer. |

If any change to this folder would violate one of those rules, it does not belong here.

## Layout

```
infra/
  profiles/
    self-hosted-vps/        # docker-compose, Kong, Traefik, Keycloak, OpenFGA, Tailscale, Splunk
    aws-managed/            # Terraform modules + an example-dev composition
    hybrid-tailnet/         # Tailscale ACL + Cloudflare tunnel examples
  policies/                 # authorization policy references (OpenFGA, OPA, Cedar)
```

## How profiles relate to `architecture/profiles/`

| Architecture doc | Reference infra |
|---|---|
| [`../architecture/profiles/self-hosted-vps.md`](../architecture/profiles/self-hosted-vps.md) | [`profiles/self-hosted-vps/`](profiles/self-hosted-vps/) |
| [`../architecture/profiles/aws-managed.md`](../architecture/profiles/aws-managed.md) | [`profiles/aws-managed/`](profiles/aws-managed/) |
| [`../architecture/profiles/hybrid-tailnet.md`](../architecture/profiles/hybrid-tailnet.md) | [`profiles/hybrid-tailnet/`](profiles/hybrid-tailnet/) |

`architecture/profiles/*.md` describes **which vendor satisfies which layer and why**. `infra/profiles/<name>/` shows **what the configuration looks like**. The two are paired but separately maintained — the architecture doc rarely changes; the infra examples evolve with vendor APIs.

## How to consume from a solution repo

Solution repos (e.g., `levelup-platform`, `trupryce`) typically:

1. Fork the relevant `infra/profiles/<name>/` tree into a sibling implementation repo (e.g., `levelup-platform-infra`).
2. Replace `.example.*` filenames with real ones; populate values from secret manager and environment.
3. Add a remote tfstate backend (e.g., S3 + DynamoDB lock) scoped to that solution's accounts.
4. Open a dependency record in [`../portfolio/dependencies/`](../portfolio/dependencies/) referencing the version of this reference they're tracking.

## Adding a new profile

If a new architecture profile is added (e.g., `azure-managed`):

1. Open an OpenSpec proposal per [`../team-os/openspec-policy.md`](../team-os/openspec-policy.md).
2. Add `architecture/profiles/azure-managed.md` (the *what and why*).
3. Add `infra/profiles/azure-managed/` (the *example configs*).
4. Update this README's profile-mapping table.

## What is NOT here

- Live infrastructure ownership.
- Production secrets or any credentials with real-world reach.
- Real account IDs, subscription IDs, project IDs.
- Customer-specific configuration.
- Operational runbooks for live environments (those live in the deploying solution repo's `docs/operations/`).
