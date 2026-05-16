# Profile: Self-Hosted VPS

> Reference configurations for this profile (Docker Compose, Kong, Traefik, Keycloak, OpenFGA, Tailscale) live under [`../../infra/profiles/self-hosted-vps/`](../../infra/profiles/self-hosted-vps/). They are examples, not live deployments.

## When to choose this profile

- Early-stage products validating market fit.
- Cost-sensitive deployments where managed services are not justified yet.
- Teams that need maximum control over the stack.
- Workloads that do not (yet) require regulator-attested managed services.

## Layer-by-layer mapping

### L1 — Network reachability

- **Cloudflare Tunnel** terminates DNS and provides outbound-only connectivity from the VPS to the public edge. The VPS does not expose ports to the public internet.
- **Tailscale** provides an authenticated mesh for operator access and (optionally) east-west service traffic.

**Contract.** Only traffic that has passed Cloudflare's edge and matches a tunnel rule reaches the VPS. Operator access flows through Tailscale, never SSH on a public IP.

### L2 — Edge gateway / routing

- **Kong CE** (Community Edition) is the public-facing gateway: TLS, routing, request validation, plugin-based WAF rules.
- **Traefik** is the internal router for Docker Compose service-to-service routing.

**Contract.** Public clients always traverse Kong. Internal services are reachable only through Traefik on a private Docker network.

### L3 — Identity

- **Keycloak** issues OIDC tokens for users, services, and agents. One realm per audience (e.g., `customers`, `internal`, `agents`).

**Contract.** Every L2-routed request that requires authentication carries a Keycloak-issued JWT verified by Kong (offline JWKS).

### L4 — Authorization

- **OpenFGA** holds the relationship-based authorization model and decides `(user, action, object)` queries.
- Kong calls OpenFGA via a gateway plugin for coarse authorization; orchestrator/BFF calls OpenFGA for fine-grained decisions.

**Contract.** No permission is decided by token claims alone.

### L5 — Operational guardrails

- Kong plugins (rate-limit, request-size, ip-restriction) with Redis as the shared counter store.
- Feature flags via a small in-house service or self-hosted Unleash/Flagsmith.

**Contract.** Guardrails apply per-tenant, per-route, per-principal-type.

### L6 — Orchestrator / BFF

- A Node or Go BFF behind Kong composes downstream services and signs the internal identity envelope (JWS/JOSE) with a key managed in Keycloak or a dedicated secrets store.

**Contract.** Internal services never see the original L3 token; they see the envelope.

### L7 — Service-level enforcement

- Services run as Docker containers. Each verifies the envelope, applies per-service authorization checks (with OpenFGA where relationship-based), and enforces tenant-scoped data access.

**Contract.** A service that does not verify the envelope is non-compliant.

### L8 — Semantic / agent reasoning

- Agent runtimes (Claude/Codex/automation) are clients. They authenticate to Keycloak as service principals, traverse Kong, and obtain envelopes from the orchestrator like any other caller.

**Contract.** Per [`../agent-as-client-model.md`](../agent-as-client-model.md).

## Observability

- **Logs:** Docker → Fluent Bit → Splunk (or Grafana Loki for lower cost).
- **Metrics:** Prometheus, scraped from Kong, Traefik, services. Grafana for dashboards.
- **Traces:** Tempo or Jaeger, instrumented via OpenTelemetry SDKs.
- **Audit:** sealed Splunk index (or append-only object store) for L3, L4, L6 envelope issuance, L7 sensitive operations.

## Failure modes

| Failure | Behavior |
|---|---|
| Cloudflare Tunnel down | Platform is unreachable. Operator access still possible via Tailscale. |
| Kong down | All public traffic fails closed. No bypass route. |
| Keycloak down | Existing tokens valid until expiry; new logins fail. |
| OpenFGA down | Authorization fails closed. Document any read-mostly cache. |
| Redis down | Rate-limit counters degrade; configure to fail-closed for sensitive routes. |

## Migration paths

- **To AWS-managed:** Kong → API Gateway/ALB; Keycloak → Cognito/Auth0 (or keep Keycloak on ECS); OpenFGA → Verified Permissions or stay; Docker Compose → ECS/EKS.
- **To hybrid tailnet:** introduce Tailscale subnet routers; keep the rest.

## Compensating controls

- WAF: Cloudflare provides L7 WAF in front of the tunnel; Kong plugins add layer 7 rules.
- DDoS: relies on Cloudflare's edge; this profile does not stand alone against volumetric attacks.
- Secrets: managed in a dedicated secrets store (Vault, Doppler, or equivalent) — **not** in environment variables baked into images.
