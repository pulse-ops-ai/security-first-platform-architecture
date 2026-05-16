# Module: `edge` — L2 reference

Reference module for **Layer 2 — Edge gateway / routing** in the AWS-managed profile. Provisions either an ALB with WAF attached, or wires up an API Gateway HTTP API behind a WAF web ACL — the consuming environment picks one via `edge_kind`.

Maps to [`../../../../../architecture/control-layers.md`](../../../../../architecture/control-layers.md) Layer 2 and Layer 5 (operational guardrails — throttling and WAF rules are configured here).

## Inputs

| Name | Description |
|---|---|
| `name` | Stable name prefix |
| `vpc_id` | From the `network` module |
| `subnet_ids` | Public subnets for ALB; ignored for API Gateway |
| `edge_kind` | One of `alb` or `api_gateway` |
| `certificate_arn` | ACM certificate for TLS |
| `waf_managed_rule_groups` | List of AWS-managed WAF rule groups to attach |
| `default_rate_limit_per_5min` | Per-IP default rate limit |
| `tags` | Common tag map |

## Outputs

- `edge_arn` — ALB or API Gateway ARN
- `edge_dns_name` — public hostname
- `waf_web_acl_arn`

## Notes

- TLS terminates here. Origins behind the edge are private.
- Throttling defaults are conservative; production tunes them per route.
- No real WAF rule sets are committed here — the consuming repo configures product-specific rules.
