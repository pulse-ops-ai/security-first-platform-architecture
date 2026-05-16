variable "name" {
  description = "Stable name prefix."
  type        = string
}

variable "operational_retention_days" {
  description = "Retention for operational log groups (app, edge, identity, authz, envelope)."
  type        = number
  default     = 30
}

variable "audit_retention_days" {
  description = "Retention for sealed audit log group. Longer; usually regulator-driven."
  type        = number
  default     = 365
}

variable "kms_deletion_window_days" {
  description = "KMS deletion window for the logs key."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
