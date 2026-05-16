# Agents Are Clients, Not Insiders

## The rule

> **Agents must authenticate, authorize, and route through the same gateway and policy chain as any other caller.**

An agent — whether an LLM-driven planner, a workflow automation, a scheduled job, or a developer-operated CLI — is an **external client** for the purpose of access control. It does not get a privileged shortcut because it runs "inside" the platform.

## Why

Agents are the highest-leverage callers in the system. They:

- act on behalf of many users,
- make many requests quickly,
- can be confused, jail-broken, or misused,
- often hold long-lived credentials.

Treating them as insiders means every agent compromise becomes a platform compromise. Treating them as clients means existing controls (gateway, identity, authorization, rate limits, audit) constrain them automatically.

## What this means concretely

1. **L1.** Agent runtimes reach the platform via the same network admission as any other client. No back-channel.
2. **L2.** All agent traffic goes through the edge gateway. WAF and routing rules apply.
3. **L3.** Agents authenticate. Their principal type is `agent`. Tokens are short-lived and obtained via a workload-identity flow (client credentials, mTLS, federated workload identity).
4. **L4.** Agent actions are authorized by the same PDP as user actions, against a policy model that explicitly names the `agent` principal type and any on-behalf-of (`actor`) relationships.
5. **L5.** Operational guardrails (rate limits, quotas, cost guards) apply to agent traffic. Agents typically need *tighter* limits than humans, not looser.
6. **L6.** The orchestrator issues an internal envelope with `principal_type=agent` and, when the agent acts on behalf of a human, populates `actor` with that human's principal. Authorization at downstream layers may consider both.
7. **L7.** Services treat `agent` calls with the same skepticism as external calls. No "trust this caller because it's the agent runtime."
8. **L8.** Semantic / reasoning components live beside the stack. When they call back in to retrieve data, invoke tools, or write results, they re-enter at L1/L2 like any other client.

## On-behalf-of (actor / sub split)

When an agent acts for a human:

- `sub` is the **agent's** principal ID.
- `actor` (or equivalent) is the **human's** principal ID.
- The PDP evaluates: "Is *agent* permitted to act on behalf of *human*? Is *human* permitted to perform *action* on *resource*? Are there obligations specific to agent-mediated access?"

Both checks must pass. An agent never gains permissions its actor lacks. An actor never gets a free pass via an agent it does not have delegation for.

## Audit

Every agent-initiated request must be auditable as `agent-initiated` with both `sub` and `actor` recorded. This is non-negotiable.

## Anti-patterns

- Agent runtime sharing a service-mesh identity with backend services.
- "The agent is part of the platform, so it can read any tenant's data."
- Long-lived API keys for agents instead of short-lived workload identities.
- Per-agent allow-lists that bypass L4.

## Where this shows up in implementation profiles

Concrete mappings for agent authentication, workload identity, and policy modeling live in [`profiles/`](profiles/). The rule — agents are clients, not insiders — is identical across profiles.
