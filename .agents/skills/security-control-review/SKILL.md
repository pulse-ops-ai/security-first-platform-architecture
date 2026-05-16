---
name: security-control-review
description: Review a change for control-layer integrity, trust-zone crossings, agent-as-client compliance, and audit emission. Use when a PR touches authentication, authorization, request routing, envelope handling, audit, agent runtime behavior, or any path crossing trust zones.
---

# Security control review

<!-- no-shim: claude — vendor-neutral procedure; .claude/commands/security-control-review.md invokes canonical directly. -->
<!-- no-shim: codex -->

For changes that touch the security stack, verify trust-zone crossings have the required evidence, agents remain clients (never insiders), and audit-class events emit to the audit sink rather than operational logs.

## Inputs

- The PR or diff under review.
- The repo's declared deployment profile.
- Path to the repo (default: current working directory).

## Procedure

1. **Trust-zone crossings.** For every code path in the change, list the trust zones it crosses (Z0–Z4 per [`../../../architecture/security-boundaries.md`](../../../architecture/security-boundaries.md)).
2. **Crossing evidence.** Confirm each crossing has the required evidence:
   - Z0→Z1: routing/WAF disposition
   - Z1→Z2: verified L3 token
   - Z2→Z3: L4 decision
   - Z3→Z4: signed internal envelope
   - Within Z4: envelope verification on every hop
3. **Network-as-identity smells.** Run the automated scanner:

   ```bash
   bash scripts/check-network-as-identity.sh .
   ```

   It looks for the following heuristic patterns and reports findings per category:

   | Category | What it catches | False-positive sources |
   |---|---|---|
   | `ip-as-identity` | `X-Forwarded-For` / `RemoteAddr` / `req.ip` used near `allow` / `permit` / `isAdmin` | logging, rate-limiting, audit metadata |
   | `internal-cidr-trust` | Hard-coded `10.x` / `172.16–31.x` / `192.168.x` CIDRs near decision verbs | metrics endpoints, debug-only routes |
   | `mesh-only-identity` | `spiffe://`, mTLS peer cert reads, workload identity claims used near `actor` / `user` / `on_behalf` | pure service-to-service paths with no end-user context (these are fine; verify by reading the call site) |
   | `fail-open` | `catch … return true`, `default: permit`, `allowed = true` | legitimate test fixtures, mocks |
   | `long-lived-cred` | AKIA-prefixed AWS access keys, JWT-shaped literals | redacted examples (the script masks output) |

   Treat all findings as WARN unless the call site confirms the smell — review each one against the security-boundaries crossing rules.
4. **Agent paths.** If agents are involved, verify they pass through L1→L4 like any other client. Verify `principal_type=agent` and `actor` are handled per [`../../../architecture/agent-as-client-model.md`](../../../architecture/agent-as-client-model.md). The `mesh-only-identity` findings from step 3 are particularly relevant here.
5. **Audit emission.** Confirm security-relevant events emit to the audit sink — not just operational logs. Grep for the audit-sink writer your profile uses (`audit_log_group_name` output for AWS-managed; sealed Splunk index for self-hosted-vps) and confirm the new code path writes there.
6. **Fail-closed verification.** For each finding in the `fail-open` category, confirm whether the path is intentional. A fail-open authz path requires an ADR documenting why and the compensating control.
7. **Secrets handling.** No secrets in logs, no long-lived credentials in code. The `long-lived-cred` category from step 3 covers the common patterns; review any masked findings against the call site.

## Output

Return a control-by-control report with `PASS` / `BLOCK` / `WARN` per area and rationale per finding. Each `BLOCK` must name the file or code path and the trust-zone rule it violates. Include the raw output of `check-network-as-identity.sh` as evidence.

Example shape:

```
Trust-zone crossings:         PASS
Crossing evidence:            PASS
Network-as-identity scan:     WARN — 2 ip-as-identity findings (see below)
Agent paths:                  PASS
Audit emission:               BLOCK — new write path missing audit sink call
Fail-closed:                  PASS
Secrets handling:             PASS

Overall: BLOCK on audit emission
```

## Guardrails

- Any `BLOCK` must be resolved before merge — do not soften findings.
- Do not approve a fail-open error path. Fail-closed is the default; fail-open requires an explicit ADR.
- Do not treat service-mesh identity or VPC membership as authentication evidence, even if the code "happens to work."
- Scanner findings are HEURISTIC. False positives are expected — review the call site before concluding.

## See also

- [`../../../architecture/security-boundaries.md`](../../../architecture/security-boundaries.md)
- [`../../../architecture/identity-and-authorization.md`](../../../architecture/identity-and-authorization.md)
- [`../../../architecture/internal-identity-envelope.md`](../../../architecture/internal-identity-envelope.md)
- [`../../../architecture/agent-as-client-model.md`](../../../architecture/agent-as-client-model.md)
- [`../../../scripts/check-network-as-identity.sh`](../../../scripts/check-network-as-identity.sh)
