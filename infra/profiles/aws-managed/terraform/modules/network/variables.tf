variable "name" {
  description = "Stable name prefix for tagging and naming (e.g., 'levelup-dev')."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC (e.g., '10.0.0.0/16')."
  type        = string
}

variable "azs" {
  description = "Availability zones to span."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR per AZ, in the same order as 'azs'."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per AZ. Empty list = fully private."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
