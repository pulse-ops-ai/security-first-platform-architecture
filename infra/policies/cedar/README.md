# Cedar — Reference Authorization Modeling

Cedar is the policy language behind AWS Verified Permissions. Choose Cedar when you want a fully managed PDP with no infrastructure to run and the workload is already on AWS.

## Reference schema

A starter Cedar schema is embedded in the [`authorization` Terraform module](../../profiles/aws-managed/terraform/modules/authorization/main.tf). It declares:

- Entity types: `User`, `Service`, `Agent` (with `actor` attribute), `Tenant`, `Resource` (member of `Tenant`).
- Actions: `view`, `edit`, `delete`, applicable to `Resource`.

This is the **shape**. Real policies extend the schema with product-specific entity types and actions.

## Example policy shapes

Cedar policies are not committed in this repo because the moment they reference real resources or principals they become solution-specific. The shapes below are illustrative:

### Principal type guard

```cedar
// A user can view a resource in their tenant.
permit (
  principal is User,
  action == Action::"view",
  resource is Resource
) when {
  principal in resource.tenant.member
};
```

### Agent-as-client with actor scope

```cedar
// An agent can act only if its actor can act, and only within its tenant.
permit (
  principal is Agent,
  action == Action::"view",
  resource is Resource
) when {
  principal.tenant == resource.tenant &&
  principal.actor in resource.tenant.member
};
```

### Tenant-admin override

```cedar
permit (
  principal is User,
  action in [Action::"edit", Action::"delete"],
  resource is Resource
) when {
  principal in resource.tenant.admin
};
```

## When to choose Cedar

- AWS-only workload; managed PDP is preferable.
- Strict schema + strict validation desired (`STRICT` validation in the policy store).
- Smaller / mid-size policy sets that don't need relationship-graph queries.

## Decision flow

1. Application (typically L6 BFF) calls `IsAuthorized` against the policy store with `principal`, `action`, `resource`, and a `context` map.
2. Verified Permissions returns `Allow` / `Deny`, plus the matching policy IDs and any `errors`.
3. Application records the `decision_id` and `reason` in the audit sink.

## What this directory does NOT contain

- Live `.cedar` policies.
- Real policy IDs.
- Bound policy templates with specific resources.

Those belong to the solution-infra repo deploying with this engine.
