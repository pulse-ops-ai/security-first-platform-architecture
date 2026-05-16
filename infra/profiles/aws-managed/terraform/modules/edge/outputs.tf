output "edge_arn" {
  description = "ARN of the edge resource (ALB or API Gateway)."
  value       = local.use_alb ? try(aws_lb.this[0].arn, null) : try(aws_apigatewayv2_api.this[0].arn, null)
}

output "edge_dns_name" {
  description = "Public DNS name of the edge resource."
  value       = local.use_alb ? try(aws_lb.this[0].dns_name, null) : try(aws_apigatewayv2_api.this[0].api_endpoint, null)
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF web ACL associated with the edge."
  value       = aws_wafv2_web_acl.this.arn
}
