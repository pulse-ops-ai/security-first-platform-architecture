# Observability

Observability is a **layer**, not a feature. Every control layer emits structured signals on a common schema, on a common pipeline. Profiles map the pipeline to concrete tools.

## Three signal classes

| Class | What it is | Owner per layer |
|---|---|---|
| **Logs** | Structured events with timestamp, principal, request_id, decision, outcome | Every layer |
| **Metrics** | Counters, gauges, histograms of layer-specific events | Every layer |
| **Traces** | Spans correlated across layers by `trace_id` and `request_id` | Every layer (sampled) |

## Common required fields

Every emitted signal must include:

- `request_id` — stable across all layers for one external request
- `trace_id` — propagated for distributed tracing
- `principal` (when known) — `sub`, `principal_type`, `tenant`
- `layer` — which control layer emitted this
- `outcome` — `permit` | `deny` | `error` | `success` | `bypass`
- `reason_code` — short, stable enum (not a free-text string)
- `timestamp` (ISO 8601, UTC)

## What each layer must emit

| Layer | Required signals |
|---|---|
| L1 — Network | Connection accepted/rejected, source descriptor |
| L2 — Edge gateway | Route matched, WAF disposition, latency |
| L3 — Identity | Token issued, token verified, token rejected (with reason_code) |
| L4 — Authorization | Decision (permit/deny), decision_id, principal, action, resource |
| L5 — Guardrails | Rate-limited, quota-exhausted, circuit-broken, flag-state |
| L6 — Orchestrator | Envelope issued (with jti), use-case invoked, downstream calls |
| L7 — Service | Operation outcome, tenant_id, envelope verification result |
| L8 — Agent / semantic | Plan, tool calls, retrieval queries, model + version, token budget |

## Audit log

A subset of events must reach a **tamper-evident audit sink**:

- All L3 issue/revoke events
- All L4 decisions for sensitive resources
- All envelope issuance (L6) for cross-tenant and on-behalf-of calls
- All L7 operations on sensitive resources
- All agent-initiated writes (L8 + L6)

Audit storage is separate from operational logs. Retention and integrity guarantees are stricter.

## Profile mappings

Concrete tooling for logs, metrics, traces, and audit sinks lives in [`profiles/`](profiles/). The required signals and schema are identical across profiles.

## Rules

- **Do not log secrets.** Tokens, envelopes, passwords, PII beyond what is required.
- **Stable reason codes.** Free-text reasons are unsearchable; enums are.
- **Sampling is allowed for traces, not for security-relevant logs.**
- **Every layer emits, every layer ships, one pipeline.** No layer-local-only logging.
