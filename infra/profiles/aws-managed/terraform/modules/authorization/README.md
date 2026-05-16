# Module: `authorization` — L4 reference

Reference module for **Layer 4 — Authorization** in the AWS-managed profile. Provisions an AWS Verified Permissions policy store with a minimal Cedar schema illustrating the principal types (`user`, `service`, `agent`) and the relationship hooks needed for the [agent-as-client model](../../../../../architecture/agent-as-client-model.md) and [multi-tenancy](../../../../../architecture/multi-tenancy.md).

For relationship-rich models, prefer OpenFGA on ECS — see [`../../../../policies/openfga/`](../../../../policies/openfga/).

Maps to [`../../../../../architecture/control-layers.md`](../../../../../architecture/control-layers.md) Layer 4 and [`../../../../../architecture/identity-and-authorization.md`](../../../../../architecture/identity-and-authorization.md).

## Inputs

| Name | Description |
|---|---|
| `name` | Stable name prefix |
| `validation_mode` | `STRICT` or `OFF` for the Cedar schema |
| `tags` | Common tag map |

## Outputs

- `policy_store_id`
- `policy_store_arn`

## Notes

- The Cedar schema here is the **starting point**. Real authorization models add per-resource action sets, attribute-based conditions, and product-specific entity types.
- Policies (`aws_verifiedpermissions_policy`) are not provisioned by this module — they belong with the application code, deployed via the solution-infra repo or CI.
- For OpenFGA-based deployments, see [`../../../../policies/openfga/README.md`](../../../../policies/openfga/README.md) and [`../../../self-hosted-vps/openfga/`](../../../self-hosted-vps/openfga/) for the model DSL.
