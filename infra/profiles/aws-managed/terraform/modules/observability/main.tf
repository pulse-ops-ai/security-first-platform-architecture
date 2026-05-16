# modules/observability/main.tf
#
# Reference module — observability.
# Provisions log groups (operational + sealed audit) plus a KMS key.
# Metrics, traces, and Splunk subscription filters are environment-specific.

locals {
  operational_classes = ["app", "edge", "identity", "authz", "envelope"]
}

resource "aws_kms_key" "logs" {
  description             = "Log encryption for ${var.name}"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true
  tags                    = merge(var.tags, { Layer = "observability" })
}

resource "aws_cloudwatch_log_group" "operational" {
  for_each = toset(local.operational_classes)

  name              = "/${var.name}/${each.value}"
  retention_in_days = var.operational_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = merge(var.tags, {
    SignalClass = each.value
    Layer       = "observability"
  })
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/${var.name}/audit"
  retention_in_days = var.audit_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = merge(var.tags, {
    SignalClass = "audit"
    Layer       = "observability"
    Sealed      = "true"
  })
}
