# OPA — Reference Authorization Modeling

Open Policy Agent (OPA) with Rego is an alternative L4 engine, useful when a single policy-as-code surface should cover application authorization, Kubernetes admission, and infrastructure policies.

## Reference patterns

This is reference-only — no live `.rego` files are committed. The patterns below capture what an OPA bundle for this architecture would look like.

### Principal types

```rego
package platform.authz

default allow = false

# Helper: principal is an agent acting on behalf of a user.
agent_acting_for_user(input) {
    input.principal.type == "agent"
    input.principal.actor != ""
}
```

### Tenant scoping

```rego
same_tenant {
    input.principal.tenant == input.resource.tenant
}

# Cross-tenant access requires explicit grant and is audited separately.
cross_tenant_grant {
    some grant in data.cross_tenant_grants
    grant.principal == input.principal.sub
    grant.target_tenant == input.resource.tenant
}
```

### Agent-as-client check

```rego
# An agent never gains permissions its actor lacks.
agent_within_actor_scope {
    input.principal.type == "agent"
    data.user_permissions[input.principal.actor][input.action][_] == input.resource.id
}

allow {
    input.principal.type == "user"
    same_tenant
    data.user_permissions[input.principal.sub][input.action][_] == input.resource.id
}

allow {
    input.principal.type == "agent"
    same_tenant
    agent_within_actor_scope
}
```

### Decision shape

Every decision returns:

```json
{
  "permit": true,
  "decision_id": "<uuid>",
  "obligations": [],
  "reason_code": "tenant_member_with_actor_grant"
}
```

The `decision_id` and `reason_code` are written to the audit sink per [`../../../architecture/observability.md`](../../../architecture/observability.md).

## When to choose OPA

- One policy engine for app authz **and** Kubernetes/Gatekeeper admission **and** CI policy checks.
- Bundle distribution model (sign + push + pull) fits your release process.
- Team is comfortable in Rego.

## Deployment

- AWS-managed: OPA sidecar to each L6/L7 service, or a centralized OPA server fronted by an internal ALB. Bundles served from S3 with signature verification.
- Self-hosted: OPA container on the same Docker network as services.

## What this directory does NOT contain

- Live `.rego` bundles.
- Decision logs.
- Bundle signing keys (those live in KMS, not source).
