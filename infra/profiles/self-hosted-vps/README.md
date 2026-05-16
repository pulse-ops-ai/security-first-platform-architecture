# Self-Hosted VPS — Reference Infrastructure

Example configurations for the self-hosted VPS profile described in [`../../../architecture/profiles/self-hosted-vps.md`](../../../architecture/profiles/self-hosted-vps.md).

> Reference only. No live secrets. Copy into a solution-specific infra repo (e.g., `<solution>-infra`) before deploying.

## Layer-by-layer mapping

| Layer | Implementation | Example asset |
|---|---|---|
| L1 — Network reachability | Cloudflare Tunnel + Tailscale | [`tailscale/acl.example.hujson`](tailscale/acl.example.hujson) |
| L2 — Edge gateway | Kong CE (public), Traefik (internal) | [`kong/kong.example.yml`](kong/kong.example.yml), [`traefik/`](traefik/) |
| L3 — Identity | Keycloak | [`keycloak/realm-export.example.json`](keycloak/realm-export.example.json) |
| L4 — Authorization | OpenFGA | [`openfga/model.fga`](openfga/model.fga), [`openfga/tuples.example.yaml`](openfga/tuples.example.yaml) |
| L5 — Operational guardrails | Kong plugins + Redis | (defined in `kong.example.yml`) |
| L6 — Orchestrator / BFF | Custom service (not in this reference) | — |
| L7 — Service-level | Docker Compose services | [`docker-compose.example.yml`](docker-compose.example.yml) |
| L8 — Semantic / agent | Agent runtime (not in this reference) | — |
| Observability | Splunk or Grafana/Loki/Prometheus/Tempo | [`splunk/README.md`](splunk/README.md) |

## How to consume

1. Copy the contents of this directory into your solution-infra repo (e.g., `levelup-platform-infra/profiles/self-hosted-vps/`).
2. Rename each `*.example.*` file to its production form.
3. Populate secrets from a secret manager (Vault, Doppler, AWS Secrets Manager, etc.) — never inline.
4. Replace `__TENANT__`, `__DOMAIN__`, and similar placeholders with real values.
5. Generate a real Keycloak realm export against your IdP and replace [`keycloak/realm-export.example.json`](keycloak/realm-export.example.json).
6. Run the [`.agents/skills/security-control-review/`](../../../.agents/skills/security-control-review/SKILL.md) skill before deploying.

## What is missing on purpose

- TLS certificates and ACME bootstrap — handled by Cloudflare Tunnel at the edge and Traefik internally; certificates are operator-specific.
- Backup / restore scripts — solution-specific.
- Concrete WAF rules — Cloudflare WAF + Kong plugins; rules depend on the app surface.
- Real Keycloak users and clients — must come from your IdP, not from this repo.
