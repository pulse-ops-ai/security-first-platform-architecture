output "operational_log_group_names" {
  description = "Names of operational log groups, keyed by signal class."
  value       = { for k, lg in aws_cloudwatch_log_group.operational : k => lg.name }
}

output "audit_log_group_name" {
  description = "Name of the sealed audit log group."
  value       = aws_cloudwatch_log_group.audit.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting log groups."
  value       = aws_kms_key.logs.arn
}
