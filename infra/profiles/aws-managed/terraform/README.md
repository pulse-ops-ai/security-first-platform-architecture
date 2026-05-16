# Terraform Reference — AWS Managed Profile

Reference Terraform code for the AWS-managed profile. Not deployable as-is.

## Conventions

- **One module per architecture layer.** Modules are named after the role they fulfill (`network`, `edge`, `identity`, `authorization`, `observability`), not the AWS service they wrap. This mirrors the [eight-layer model](../../../../architecture/control-layers.md) so reviewers can map Terraform to architecture at a glance.
- **Provider versions are pinned in each example environment**, not in modules.
- **No remote backend in this repo.** Real deployments configure backend in their own solution-infra repo. Examples here intentionally omit `backend "s3"` blocks (or leave them commented).
- **Variables describe inputs, not defaults for production.** Defaults are illustrative.
- **Outputs are minimal**, exposing only what a composing environment needs.
- **No `data` blocks that hit a real account.** Examples may use placeholder values or `terraform plan -refresh=false`.

## Layout

```
modules/
  network/         # L1 — VPC, subnets, security groups
  edge/            # L2 — ALB / API Gateway, WAF
  identity/        # L3 — Cognito user pool
  authorization/   # L4 — Verified Permissions policy store
  observability/   # — CloudWatch + audit sink
environments/
  example-dev/     # composition example
```

## Composing into a solution-infra repo

A solution-infra repo typically pulls these modules via:

```hcl
module "network" {
  source = "git::https://github.com/<org>/security-first-platform-architecture.git//infra/profiles/aws-managed/terraform/modules/network?ref=<sha>"
  # ... inputs
}
```

Pin to a Git SHA or tag. Do not consume from `main`.

## What is NOT here

- A real `versions.tf` with strict provider pins (provided per-environment).
- IAM roles with real ARNs.
- KMS key policies (operator-specific).
- Backend configuration.
- State import scripts.

Those belong in the solution-infra repo, not the architecture repo.
