# Splunk — Observability for self-hosted-vps

The self-hosted-vps profile centralizes logs, metrics, and audit events into Splunk (or a Splunk-compatible target). This folder is **reference-only** — Splunk configurations are highly operator-specific and depend on your license tier, deployment topology, and data retention policy. We do not commit working `inputs.conf` / `props.conf` files here.

## What this profile expects

Per [`../../../../architecture/observability.md`](../../../../architecture/observability.md), every layer emits structured signals on a common schema. For the self-hosted-vps profile that means:

| Signal | Source | Splunk destination (suggested) |
|---|---|---|
| Application logs | Docker containers via Fluent Bit | `index=app_logs` |
| Edge access logs | Kong access log | `index=edge_logs` |
| Internal access logs | Traefik access log | `index=internal_logs` |
| Identity events | Keycloak event listener | `index=identity_audit` (sealed) |
| Authorization decisions | OpenFGA logs | `index=authz_audit` (sealed) |
| Envelope issuance & verification | BFF / services | `index=envelope_audit` (sealed) |
| Service operations | Application code | `index=app_audit` (sealed for sensitive ops) |

Sealed indexes are append-only with stricter retention and access controls. Operational and audit data **must not** share an index.

## Wiring it up (sketch — not a full guide)

1. Deploy a Splunk Universal Forwarder on the VPS host (or use Fluent Bit → HTTP Event Collector).
2. Define one input per source, keyed by index above.
3. Tag every event with `repo`, `tenant`, `principal_type`, `request_id` for joinability.
4. Configure `props.conf` to parse the structured JSON each layer emits.

A real solution-infra repo will commit specific `inputs.conf` / `props.conf` for its environments. This repo does not.

## Why no example files

Splunk configurations contain enough environment-specific paths, HEC tokens, and forwarder identity to make even an "example" risky to commit. The architecture doc lists what to emit; your solution-infra repo wires it up.

## Alternative observability stacks

If Splunk is not viable (cost, licensing, sovereignty), the self-hosted-vps profile also supports:

- Grafana Loki for logs
- Prometheus for metrics
- Tempo / Jaeger for traces
- An append-only object store (e.g., S3 with object lock) or a separate Loki tenant for audit retention

The architecture contract is the same: emit the required signals to the required class of sink, separately from operational data.
