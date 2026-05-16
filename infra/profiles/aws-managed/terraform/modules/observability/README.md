# Module: `observability` — observability reference

Reference module for the cross-cutting **observability** concern in the AWS-managed profile. Provisions:

- A CloudWatch log group per signal class (app, edge, identity, authz, envelope, audit).
- A separate, locked-down log group for **audit** events with stricter retention.
- A KMS key for log encryption.

Maps to [`../../../../../architecture/observability.md`](../../../../../architecture/observability.md).

## Inputs

| Name | Description |
|---|---|
| `name` | Stable name prefix |
| `operational_retention_days` | Retention for app/edge/identity/authz/envelope logs |
| `audit_retention_days` | Retention for sealed audit logs (longer, regulator-driven) |
| `kms_deletion_window_days` | KMS deletion window |
| `tags` | Common tag map |

## Outputs

- `operational_log_group_names`
- `audit_log_group_name`
- `kms_key_arn`

## Notes

- Audit logs go to a **separate** log group with stricter access. The IAM split is in the consuming environment, not here.
- Sampling for traces is left to the application; this module only provisions log destinations.
- Splunk forwarding (if used) is configured per environment via a CloudWatch subscription filter — not here.
