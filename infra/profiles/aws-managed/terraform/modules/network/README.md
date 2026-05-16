# Module: `network` — L1 reference

Reference module for **Layer 1 — Network reachability** in the AWS-managed profile. Provisions a VPC with private subnets for workloads, optional public subnets only for managed ingress, and security-group skeletons.

Maps to [`../../../../../architecture/control-layers.md`](../../../../../architecture/control-layers.md) Layer 1, and to [`../../../../../architecture/profiles/aws-managed.md`](../../../../../architecture/profiles/aws-managed.md) §L1.

## Inputs

| Name | Description |
|---|---|
| `name` | Stable name prefix (e.g., `levelup-dev`) |
| `cidr_block` | Top-level VPC CIDR (e.g., `10.0.0.0/16`) |
| `azs` | List of availability zones |
| `private_subnet_cidrs` | One per AZ |
| `public_subnet_cidrs` | One per AZ; `[]` if fully private |
| `tags` | Common tag map |

## Outputs

- `vpc_id`
- `private_subnet_ids`
- `public_subnet_ids`
- `default_security_group_id`

## Notes

- Security groups intentionally start empty. **No `0.0.0.0/0` ingress** anywhere.
- NAT gateways and egress filtering are operator-specific and not provisioned here.
- PrivateLink endpoints are typically added in a sibling module per workload.
