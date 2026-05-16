variable "name" {
  description = "Stable name prefix."
  type        = string
}

variable "mfa_configuration" {
  description = "MFA setting for the user pool: OFF | ON | OPTIONAL."
  type        = string
  default     = "ON"
  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "mfa_configuration must be one of: OFF, ON, OPTIONAL."
  }
}

variable "password_minimum_length" {
  description = "Minimum password length."
  type        = number
  default     = 12
}

variable "access_token_validity_minutes" {
  description = "Access token validity in minutes (short-lived; clients refresh)."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
