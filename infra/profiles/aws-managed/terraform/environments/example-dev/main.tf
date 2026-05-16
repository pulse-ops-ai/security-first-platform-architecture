# environments/example-dev/main.tf
#
# REFERENCE ONLY — NOT DEPLOYABLE AS-IS.
#
# This file composes the modules under ../../modules/ to show what a small
# dev environment would look like. It deliberately:
#
#   - has NO backend block (state is not persisted)
#   - uses placeholder names, no real account ID, no real region
#   - does not declare app clients, listeners, target groups, or services
#   - is not wired to any real network or IAM identity
#
# Copy this file into your solution-infra repo, configure a real remote
# backend, replace the locals, and fill in the missing wiring before
# running `terraform plan`.

terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # No backend here on purpose. Real environments use:
  #
  # backend "s3" {
  #   bucket         = "<solution>-tfstate-<env>"
  #   key            = "aws-managed/<env>.tfstate"
  #   region         = "<your-region>"
  #   dynamodb_table = "<solution>-tflock-<env>"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region

  # Real environments rely on workload identity (OIDC) or named profiles —
  # not on inline credentials. Do not add `access_key` / `secret_key` here.
}

locals {
  name = "${var.solution_name}-${var.environment}"

  tags = {
    Solution    = var.solution_name
    Environment = var.environment
    Profile     = "aws-managed"
    Repo        = "security-first-platform-architecture (reference)"
  }
}

# ---- L1 — Network ----
module "network" {
  source = "../../modules/network"

  name                 = local.name
  cidr_block           = var.vpc_cidr
  azs                  = var.azs
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  tags                 = local.tags
}

# ---- L2 — Edge ----
module "edge" {
  source = "../../modules/edge"

  name                        = local.name
  vpc_id                      = module.network.vpc_id
  subnet_ids                  = module.network.public_subnet_ids
  edge_kind                   = var.edge_kind
  certificate_arn             = var.certificate_arn
  waf_managed_rule_groups     = var.waf_managed_rule_groups
  default_rate_limit_per_5min = var.default_rate_limit_per_5min
  tags                        = local.tags
}

# ---- L3 — Identity ----
module "identity" {
  source = "../../modules/identity"

  name              = local.name
  mfa_configuration = var.mfa_configuration
  tags              = local.tags
}

# ---- L4 — Authorization ----
module "authorization" {
  source = "../../modules/authorization"

  name = local.name
  tags = local.tags
}

# ---- Observability ----
module "observability" {
  source = "../../modules/observability"

  name                       = local.name
  operational_retention_days = var.operational_retention_days
  audit_retention_days       = var.audit_retention_days
  tags                       = local.tags
}
