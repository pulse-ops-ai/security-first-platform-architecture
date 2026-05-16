variable "name" {
  description = "Stable name prefix."
  type        = string
}

variable "validation_mode" {
  description = "Cedar validation mode: STRICT (recommended) or OFF."
  type        = string
  default     = "STRICT"
  validation {
    condition     = contains(["STRICT", "OFF"], var.validation_mode)
    error_message = "validation_mode must be STRICT or OFF."
  }
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
