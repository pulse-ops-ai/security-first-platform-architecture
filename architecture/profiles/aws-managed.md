# Profile: AWS Managed

> Reference Terraform modules and an example composition for this profile live under [`../../infra/profiles/aws-managed/`](../../infra/profiles/aws-managed/). Not deployable as-is — fork into a solution-infra repo, configure a real remote backend, and replace placeholders before plan/apply.

## When to choose this profile

- Workloads with regulator-attested managed-services requirements.
- Teams that prefer to outsource undifferentiated heavy lifting.
- Deployments expecting significant scale, multi-AZ, or multi-region.
- Products where operations cost is dominated by people, not infrastructure.

## Layer-by-layer mapping

### L1 — Network reachability

- **VPC** with private subnets for compute and data, public subnets only for managed ingress.
- **AWS PrivateLink** for service-to-service connectivity that crosses accounts or VPCs without traversing the public internet.
- **Security groups + NACLs** as defense-in-depth, not as identity.

**Contract.** Workloads run in private subnets. Operator access via SSO + Session Manager, not direct SSH.

### L2 — Edge gateway / routing

Either:

- **API Gateway** (HTTP API or REST API) for fine-grained request control, request validation, and built-in throttling; **or**
- **ALB / NLB** for high-throughput or non-HTTP workloads.

**AWS WAF** is attached to whichever edge is used.

**Contract.** Public traffic terminates at a managed gateway. Origins are private.

### L3 — Identity

Choose one (or combine for federation):

- **Amazon Cognito** user pools for first-party identity.
- **Auth0** for hosted identity with strong developer experience.
- **Self-managed Keycloak** on ECS/EKS when full control is needed.

**Contract.** Tokens are JWTs verifiable offline at L2 and L6 via JWKS.

### L4 — Authorization

Choose one:

- **AWS Verified Permissions** (Cedar policy language) for managed fine-grained authorization.
- **OpenFGA** on ECS/EKS for relationship-based modeling.
- **OPA** for policy-as-code workflows.

**Contract.** Decisions are made by the PDP, not by token claims alone.

### L5 — Operational guardrails

- API Gateway usage plans + throttling.
- AWS WAF rate-based rules.
- **AWS AppConfig** for feature flags with deployment safety.

**Contract.** Tenant- and principal-type-aware limits applied at the edge.

### L6 — Orchestrator / BFF

- BFF runs on **ECS** (Fargate) or **EKS**.
- Internal identity envelope signed with keys held in **AWS KMS** (or asymmetric JWKS rotation via Secrets Manager).

**Contract.** Internal services receive only the envelope, never the L3 token.

### L7 — Service-level enforcement

- Services run on ECS / EKS / Lambda.
- Verify envelope using KMS-issued public key or rotated JWKS.
- Tenant scoping enforced at the data boundary (RDS row-level security, DynamoDB partition keys per tenant, S3 prefix scoping with IAM).

**Contract.** No service trusts VPC membership as identity.

### L8 — Semantic / agent reasoning

- Agent runtimes are clients. They use **IAM Roles Anywhere**, **IRSA** (EKS), or workload-identity from on-prem to obtain workload credentials, then authenticate to L3 like any other caller.

**Contract.** Per [`../agent-as-client-model.md`](../agent-as-client-model.md).

## Observability

- **Logs:** CloudWatch Logs + ship to Splunk (or stay on CloudWatch).
- **Metrics:** CloudWatch Metrics; Managed Prometheus where workload-native exporters exist.
- **Traces:** AWS X-Ray and/or OpenTelemetry Collector → Splunk APM / Tempo.
- **Audit:** CloudTrail for AWS control-plane; service-level audit to Splunk sealed index.

## Failure modes

| Failure | Behavior |
|---|---|
| API Gateway / ALB outage in a region | Fail to secondary region (if multi-region) or fail closed. |
| Cognito / Auth0 outage | Existing tokens valid until expiry; new logins fail. |
| Verified Permissions / OpenFGA outage | Authorization fails closed. |
| KMS outage | Envelope signing fails; orchestrator returns 503. |

## Migration paths

- **From self-hosted VPS:** lift Keycloak (keep) or migrate to Cognito/Auth0; replace Kong with API Gateway/ALB; move OpenFGA to ECS or replace with Verified Permissions; move services to ECS/EKS.
- **To hybrid tailnet:** add Tailscale subnet routers in a dedicated VPC for on-prem connectivity; everything else unchanged.

## Compensating controls

- **DDoS:** AWS Shield (Standard by default; Advanced for higher-risk workloads).
- **Secrets:** AWS Secrets Manager + KMS; no plaintext secrets in task definitions.
- **Egress control:** VPC endpoints + NAT with egress filtering (e.g., AWS Network Firewall) for sensitive workloads.
