# modules/network/main.tf
#
# Reference module — Layer 1 (Network reachability).
# Not deployable as-is. Pin provider versions in the consuming environment.

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name  = var.name
    Layer = "L1-network"
  })
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in var.azs : az => var.private_subnet_cidrs[idx] }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(var.tags, {
    Name = "${var.name}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_subnet" "public" {
  for_each = length(var.public_subnet_cidrs) == 0 ? {} : { for idx, az in var.azs : az => var.public_subnet_cidrs[idx] }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false # explicit; no implicit public IPs

  tags = merge(var.tags, {
    Name = "${var.name}-public-${each.key}"
    Tier = "public"
  })
}

# Default security group is intentionally locked to deny-all.
# Workload-specific SGs are defined per service in higher modules.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  # No ingress, no egress. Explicit empty blocks make the intent clear.
  tags = merge(var.tags, {
    Name = "${var.name}-default-deny"
  })
}
