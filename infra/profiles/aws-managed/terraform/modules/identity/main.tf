# modules/identity/main.tf
#
# Reference module — Layer 3 (Identity).
# Provisions a Cognito user pool only. Federation, identity providers,
# custom UI, and app clients are wired by the consuming environment.

resource "aws_cognito_user_pool" "this" {
  name = "${var.name}-users"

  mfa_configuration = var.mfa_configuration

  password_policy {
    minimum_length    = var.password_minimum_length
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true # explicit; sign-up flows are opt-in
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  tags = merge(var.tags, { Layer = "L3-identity" })
}

# App clients are intentionally not declared here. Real environments add
# one client per audience (bff, agent-runtime, etc.) with appropriate
# OAuth flows and scopes. Each client secret must be written to Secrets
# Manager and referenced — never embedded in Terraform.
