# ADR-0002: Agents are clients, not insiders

- **Status:** accepted
- **Date:** 2026-05-16
- **Authors:** @mike (retroactive capture of decision embedded in PR-1)
- **Related:** [`architecture/agent-as-client-model.md`](../../architecture/agent-as-client-model.md), [`architecture/security-boundaries.md`](../../architecture/security-boundaries.md), [ADR-0001](ADR-0001-adopt-eight-layer-control-model.md), PR #1

## Context

Agentic systems — LLM-driven planners, workflow automations, scheduled jobs, developer-operated CLIs — are the highest-leverage callers in a modern platform. A single agent can act on behalf of many users, make many requests quickly, and hold long-lived credentials. Two natural integration patterns exist:

1. **Agent as insider.** The agent runtime sits inside the platform's trust boundary and bypasses some or all of the gateway / identity / authorization chain. Justified by performance, "the agent is part of the platform," or implementation expedience.
2. **Agent as client.** The agent runtime is external to the platform's trust boundary, even when co-located. It authenticates, authorizes, and routes through the same controls as any other caller.

The "agent as insider" pattern is the dominant failure mode we observed in early prototypes: a confused, jail-broken, or compromised agent immediately becomes a platform compromise because the agent runtime's privileges are the platform's privileges. The pattern also makes audit and on-behalf-of accounting impossible: when an agent acts for a user, no record distinguishes "agent X did Y" from "user Z asked agent X to do Y."

The platform must support agentic workloads without inheriting their blast radius.

## Decision

**Agents are clients, not insiders.** Every agent — regardless of co-location, deployment proximity, or implementation language — authenticates at L3, authorizes at L4, traverses L2's edge gateway, and operates under L5's operational guardrails. No agent gets a privileged back-channel. The eight-layer model treats L8 (semantic / agent reasoning) as a peer of any other client surface, not as a privileged consumer of L1-L7.

Specifically:

- Agents authenticate with `principal_type=agent` at L3. The identity provider issues short-lived tokens via a workload-identity flow (client credentials, mTLS, federated workload identity).
- When an agent acts on behalf of a human, the request carries both `principal_type=agent` (the agent's own identity) and an `actor` claim (the human's principal). L4 evaluates both: the agent must be permitted to act on behalf of that actor, and the actor must be permitted the requested action.
- L5 guardrails apply to agent traffic; agents typically need *tighter* limits than human clients, not looser.
- L6 issues the internal identity envelope with the agent's principal AND the actor claim, so L7 services see the full chain.
- L7 services treat `agent` calls with the same skepticism as external calls. No "trust this caller because it's the agent runtime."
- The audit log records every agent-initiated request with both `sub` (agent) and `actor` (human-on-behalf-of) populated. Non-negotiable.

## Consequences

- **Positive.** Every existing control (gateway, identity, authorization, rate limits, audit) automatically constrains agents. Agent compromise is bounded to the agent's policy scope, which is itself a subset of any actor's scope. On-behalf-of accounting is correct by construction. The same audit query answers "what did human Z authorize agent X to do?" and "what did agent X do without an actor?" Future agent runtimes integrate by issuing them L3 credentials, not by carving exception paths.
- **Negative.** Every agent call incurs the same identity + authorization round-trip as a human request. Latency is bounded but non-zero. Operationally, the team must provision and rotate agent credentials, model the agent-actor relationships in the authorization store, and tune L5 limits separately for `principal_type=agent`.
- **Neutral.** Forces explicit policy modeling for agents. Teams that have implicit "trust the agent runtime" assumptions in their existing code must surface and replace them. This is work, but it's work that catches real bugs.

## Alternatives considered

- **Agent runtime as trusted insider, sharing service-mesh identity.** Considered because it's the lowest-friction integration and has the smallest latency hit. Rejected because the blast radius of any agent compromise becomes the blast radius of the workload's mesh identity — which typically has cross-tenant or admin reach in real deployments. The architecture's separation between identity (L3) and network position is the principle we'd be violating.
- **Per-agent allow-list at L4.** Considered as a middle ground — agents authenticate but bypass policy decisions via a maintained allow-list. Rejected because (a) it doesn't scale beyond a handful of agents, (b) the allow-list becomes the security model, (c) auditing "why was this allowed" requires diffing the allow-list across time, which is exactly what L4's decision logs already do.
- **Agents as a special principal type with elevated default permissions.** Considered because it would let teams ship faster initially. Rejected because "elevated default" is the failure mode this ADR exists to prevent. Defaults should be the same for all principals; differences come from the policy model, not from privileged surface.
- **Mesh-only identity (mTLS peer cert as authentication).** Considered for service-to-service paths. Rejected because mesh identity identifies the *workload* — it does not identify *which end-user or agent originated the call*. It's a useful signal at L1/L2 for network admission, but it's not authentication at L3.

## References

- [`architecture/agent-as-client-model.md`](../../architecture/agent-as-client-model.md) — the canonical statement of the rule
- [`architecture/security-boundaries.md`](../../architecture/security-boundaries.md) — trust zones Z0-Z4 and the evidence required at each crossing
- [`architecture/identity-and-authorization.md`](../../architecture/identity-and-authorization.md) — how `principal_type=agent` and `actor` flow through L3 and L4
- [`.agents/skills/security-control-review/SKILL.md`](../../.agents/skills/security-control-review/SKILL.md) — agent-path checks during PR review
- Related ADRs: [ADR-0001](ADR-0001-adopt-eight-layer-control-model.md), [ADR-0003](ADR-0003-internal-identity-envelope-as-z4-trust.md)
- PR #1 — initial scaffold

---

**Note.** Once status moves to `accepted`, this file is **immutable**. Reverse the decision by writing a new ADR that supersedes this one.
