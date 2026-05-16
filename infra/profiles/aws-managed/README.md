# AWS Managed — Reference Infrastructure

Reusable Terraform modules and an example composition for the AWS-managed profile described in [`../../../architecture/profiles/aws-managed.md`](../../../architecture/profiles/aws-managed.md).

> Reference only. No production tfstate. No tenant credentials. No account IDs. Fork into a solution-infra repo (`<solution>-infra`) before deploying.

## Layer-by-layer mapping

| Layer | Implementation | Reference module |
|---|---|---|
| L1 — Network reachability | VPC, private subnets, PrivateLink | [`terraform/modules/network/`](terraform/modules/network/) |
| L2 — Edge gateway | API Gateway / ALB / NLB + WAF | [`terraform/modules/edge/`](terraform/modules/edge/) |
| L3 — Identity | Cognito user pool (or Auth0 / Keycloak hand-off) | [`terraform/modules/identity/`](terraform/modules/identity/) |
| L4 — Authorization | Verified Permissions policy store (or OpenFGA on ECS) | [`terraform/modules/authorization/`](terraform/modules/authorization/) |
| L5 — Operational guardrails | API Gateway throttling, WAF rate rules, AppConfig | (configured inside the `edge` module) |
| L6/L7 — Orchestrator / services | ECS / EKS / Lambda (solution-specific) | _not in this reference_ |
| Observability | CloudWatch Logs / Metrics, X-Ray, sealed audit | [`terraform/modules/observability/`](terraform/modules/observability/) |

## Layout

```
terraform/
  README.md
  modules/
    network/         # VPC, subnets, security groups
    edge/            # ALB or API Gateway, WAF
    identity/        # Cognito user pool
    authorization/   # Verified Permissions policy store
    observability/   # CloudWatch log groups, audit sinks
  environments/
    example-dev/     # Composition example — NOT deployable
      main.tf
      variables.tf
      terraform.tfvars.example
```

## How to consume

1. Fork the `terraform/` tree into your solution-infra repo (e.g., `levelup-platform-infra/profiles/aws-managed/terraform/`).
2. Configure a real remote backend (S3 + DynamoDB lock, or Terraform Cloud workspace) scoped to that solution's accounts.
3. Replace `example-dev` with your real environments (`dev`, `staging`, `prod`).
4. Wire OIDC federation from GitHub Actions to AWS — no long-lived AWS keys.
5. Run the [`.agents/skills/architecture-review/`](../../../.agents/skills/architecture-review/SKILL.md) and [`.agents/skills/security-control-review/`](../../../.agents/skills/security-control-review/SKILL.md) skills before plan/apply.

## Rules

- **No remote backend** in this repo's example. `example-dev` is not deployable as-is and must not be deployed against any real account.
- **No real account IDs, AWS region defaults beyond placeholder, or subscription IDs.**
- **Modules are intentionally minimal.** They demonstrate inputs/outputs and resource shape, not feature completeness. Production-grade modules extend these or use vetted community modules (terraform-aws-modules, etc.) as the base.
