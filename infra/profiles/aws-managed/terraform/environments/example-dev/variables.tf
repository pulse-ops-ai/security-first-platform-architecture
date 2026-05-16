variable "solution_name" {
  description = "Solution name (e.g., levelup-platform)."
  type        = string
}

variable "environment" {
  description = "Environment label (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region. No default — must be set per environment."
  type        = string
}

variable "vpc_cidr" {
  description = "Top-level VPC CIDR."
  type        = string
}

variable "azs" {
  description = "Availability zones."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ. Empty for fully private."
  type        = list(string)
  default     = []
}

variable "edge_kind" {
  description = "Edge implementation: alb | api_gateway."
  type        = string
  default     = "alb"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the edge listener."
  type        = string
  default     = ""
}

variable "waf_managed_rule_groups" {
  description = "AWS-managed WAF rule groups to attach."
  type        = list(string)
  default     = ["AWSManagedRulesCommonRuleSet", "AWSManagedRulesKnownBadInputsRuleSet"]
}

variable "default_rate_limit_per_5min" {
  description = "Default per-IP rate limit per 5 minutes."
  type        = number
  default     = 2000
}

variable "mfa_configuration" {
  description = "MFA setting for the Cognito user pool."
  type        = string
  default     = "ON"
}

variable "operational_retention_days" {
  description = "Retention for operational log groups."
  type        = number
  default     = 30
}

variable "audit_retention_days" {
  description = "Retention for sealed audit log group."
  type        = number
  default     = 365
}
