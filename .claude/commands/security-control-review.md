---
argument-hint: "[optional: path to scan, default current dir]"
---

# Security control review

Run the `security-control-review` skill against the current repo (or the supplied path). Canonical procedure: [`../../.agents/skills/security-control-review/SKILL.md`](../../.agents/skills/security-control-review/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. Resolve the scan path. If `$ARGUMENTS` is non-empty and resolves to a directory, use it; otherwise default to `.`.
2. List trust-zone crossings affected by the change (Z0–Z4 per `architecture/security-boundaries.md`).
3. Run the network-as-identity scanner:

   ```bash
   bash scripts/check-network-as-identity.sh <path>
   ```

   Group findings by category (`ip-as-identity`, `internal-cidr-trust`, `mesh-only-identity`, `fail-open`, `long-lived-cred`) and review each against the call site. Findings are HEURISTIC — false positives expected.
4. Walk through the agent-as-client and audit-emission checks per the skill.
5. Return the report shape defined in the skill.

## Guardrails

- Any `BLOCK` finding must be resolved before merge — no exceptions.
- Fail-open authz paths require an ADR explaining why and the compensating control.
- Never echo a real credential value; the scanner already masks them.
- Network membership (VPC, tailnet, service mesh) is never identity. If the code treats it as identity, flag it.
