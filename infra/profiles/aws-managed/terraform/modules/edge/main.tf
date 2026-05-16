# modules/edge/main.tf
#
# Reference module — Layer 2 (Edge gateway / routing).
# Demonstrates the shape; real deployments customize WAF rules, listeners,
# target groups, and route integrations per product.

locals {
  use_alb         = var.edge_kind == "alb"
  use_api_gateway = var.edge_kind == "api_gateway"
}

# ---- WAF web ACL (applied to either edge kind) ----

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.name}-edge"
  description = "Edge WAF for ${var.name}"
  scope       = local.use_alb ? "REGIONAL" : "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.waf_managed_rule_groups
    content {
      name     = rule.value
      priority = index(var.waf_managed_rule_groups, rule.value) + 1

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${rule.value}"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "rate-limit-default"
    priority = 100

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.default_rate_limit_per_5min
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-rate-limit-default"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-edge"
    sampled_requests_enabled   = true
  }

  tags = merge(var.tags, { Layer = "L2-edge" })
}

# ---- ALB path ----

resource "aws_lb" "this" {
  count              = local.use_alb ? 1 : 0
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  drop_invalid_header_fields = true

  tags = merge(var.tags, { Layer = "L2-edge" })
}

# Listener intentionally omitted — real environments wire listeners to
# their target groups. This module exposes the LB and WAF; downstream
# wiring is product-specific.

resource "aws_wafv2_web_acl_association" "alb" {
  count        = local.use_alb ? 1 : 0
  resource_arn = aws_lb.this[0].arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# ---- API Gateway path ----

resource "aws_apigatewayv2_api" "this" {
  count         = local.use_api_gateway ? 1 : 0
  name          = "${var.name}-api"
  protocol_type = "HTTP"

  tags = merge(var.tags, { Layer = "L2-edge" })
}

# Stage / integrations are product-specific and not provisioned here.
