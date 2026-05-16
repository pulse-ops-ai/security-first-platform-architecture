output "vpc_id" {
  description = "The VPC ID."
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs, ordered by AZ."
  value       = [for s in aws_subnet.private : s.id]
}

output "public_subnet_ids" {
  description = "Public subnet IDs, ordered by AZ. Empty if fully private."
  value       = [for s in aws_subnet.public : s.id]
}

output "default_security_group_id" {
  description = "The locked-down default security group. Use workload-specific SGs for real traffic."
  value       = aws_default_security_group.this.id
}
