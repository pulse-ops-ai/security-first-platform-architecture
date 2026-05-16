# OpenFGA — Reference Authorization Modeling

OpenFGA is the relationship-based engine used by the self-hosted-vps profile and available on AWS-managed when relationship modeling is preferred over Cedar.

## Reference model

A starter model is committed under [`../../profiles/self-hosted-vps/openfga/model.fga`](../../profiles/self-hosted-vps/openfga/model.fga). It demonstrates:

- **Principals**: `user`, `service`, `agent`
- **Tenancy**: `tenant` with `member`, `admin`, `service_account`
- **Agent-as-client**: `agent.actor: user`, `agent.provisioned_in: tenant`
- **Resource pattern**: `resource.tenant`, `owner`, `viewer`, `editor`, `deleter`

Use this as the **starting point**. Real products extend it with their own resource types and action sets.

## Test fixtures

[`../../profiles/self-hosted-vps/openfga/tuples.example.yaml`](../../profiles/self-hosted-vps/openfga/tuples.example.yaml) shows the shape of tuples and assertions, including the agent-acting-for-user case that's central to the platform.

Real test suites live in the consuming solution-infra repo (e.g., `levelup-platform-infra/policies/openfga/`) and exercise product-specific resources.

## When to use OpenFGA over the other engines

Choose OpenFGA when:

- Permissions are best expressed as relationships ("user X can view document Y because X is a member of team Z which has access to folder F containing Y").
- You need both ReBAC and the ability to query "who can do X to Y?" or "what can principal P access?".
- You want the same engine on self-hosted and managed deployments without rewriting policies.

Choose Cedar (Verified Permissions) instead when you want a managed PDP with no infra to run. Choose OPA when you want policy-as-code with a broader pattern fit (admission control, infra policies, app authz in one engine).

## Deployment

- Self-hosted: Docker Compose, Postgres backend in production.
- AWS-managed: ECS or EKS task with RDS Postgres; service-to-service over the VPC.
- Either profile uses the same `model.fga` and tuple shapes.

## What this directory does NOT contain

- Product-specific resource types or actions.
- Live tuples or production policy fixtures.
- Operational runbooks (backup, restore, model migration).
