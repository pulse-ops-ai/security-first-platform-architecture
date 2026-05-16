# Module: `identity` — L3 reference

Reference module for **Layer 3 — Identity** in the AWS-managed profile. Provisions a Cognito user pool with sane defaults for a first-party identity store. Federation, custom flows, and Auth0 / Keycloak hand-offs are operator-specific and not provisioned here.

Maps to [`../../../../../architecture/control-layers.md`](../../../../../architecture/control-layers.md) Layer 3 and [`../../../../../architecture/identity-and-authorization.md`](../../../../../architecture/identity-and-authorization.md).

## Inputs

| Name | Description |
|---|---|
| `name` | Stable name prefix |
| `mfa_configuration` | `OFF`, `ON`, or `OPTIONAL` |
| `password_minimum_length` | Minimum password length |
| `access_token_validity_minutes` | Short — defaults to 5 |
| `tags` | Common tag map |

## Outputs

- `user_pool_id`
- `user_pool_arn`
- `user_pool_issuer`

## Notes

- Access tokens are short-lived. Refresh is handled by the client.
- Tokens are JWTs, verifiable offline at L2 and L6 via the issuer JWKS.
- App clients are not provisioned here; the consuming environment defines clients per audience (`bff`, `agent-runtime`, etc.) and emits client secrets via Secrets Manager.
