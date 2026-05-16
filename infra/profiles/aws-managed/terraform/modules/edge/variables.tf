variable "name" {
  description = "Stable name prefix."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID (from the network module)."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs. Public subnets for ALB; ignored for api_gateway."
  type        = list(string)
  default     = []
}

variable "edge_kind" {
  description = "Which edge implementation: 'alb' or 'api_gateway'."
  type        = string
  validation {
    condition     = contains(["alb", "api_gateway"], var.edge_kind)
    error_message = "edge_kind must be one of: alb, api_gateway."
  }
}

variable "certificate_arn" {
  description = "ACM certificate ARN for TLS termination at the edge."
  type        = string
  default     = ""
}

variable "waf_managed_rule_groups" {
  description = "Names of AWS-managed WAF rule groups to attach (e.g., AWSManagedRulesCommonRuleSet)."
  type        = list(string)
  default     = []
}

variable "default_rate_limit_per_5min" {
  description = "Per-IP rate limit per 5 minutes for the default WAF rate rule."
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
