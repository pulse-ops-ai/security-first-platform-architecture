# docs/product/ — Product entry point

The product surface for **`security-first-platform-architecture`**. Read this if you are a stakeholder, product owner, sponsor, auditor, or consuming-repo lead asking *what does this repo promise, what doesn't it promise, who owns it, and how do my repos adopt it.*

For engineering depth, use [`../../architecture/INDEX.md`](../../architecture/INDEX.md). For operational runbooks, use [`../operations/INDEX.md`](../operations/INDEX.md). For trade-off rationale, use [`../decisions/INDEX.md`](../decisions/INDEX.md).

## What this repo is

A reusable, vendor-neutral **security-first platform architecture** plus the **TeamOS adoption kit** that lets multiple solution repos (`trupryce`, `findevil`, `levelup-platform`, …) consume a shared architectural contract without each rebuilding it.

## What this repo promises

| Promise | Where it lives | Stability |
|---|---|---|
| A stable eight-layer control model that survives vendor changes | [`../../architecture/control-layers.md`](../../architecture/control-layers.md), [`ADR-0001`](../decisions/ADR-0001-adopt-eight-layer-control-model.md) | Tier 3 to change |
| Agents are clients, not insiders — every agent traverses the same controls | [`../../architecture/agent-as-client-model.md`](../../architecture/agent-as-client-model.md), [`ADR-0002`](../decisions/ADR-0002-agents-are-clients-not-insiders.md) | Tier 3 to change |
| A canonical internal-trust mechanism (the identity envelope) for service-to-service calls | [`../../architecture/internal-identity-envelope.md`](../../architecture/internal-identity-envelope.md), [`ADR-0003`](../decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md) | Tier 3 to change |
| A repo contract that consuming repos can adopt and a validator that confirms alignment | [`../../standards/repo-contract.md`](../../standards/repo-contract.md), [`../../scripts/validate-architecture.sh`](../../scripts/validate-architecture.sh) | Tier 2 to change |
| OpenSpec governance: cross-repo changes require an explicit proposal, affected-consumer list, and dependency record | [`../../team-os/openspec-policy.md`](../../team-os/openspec-policy.md), [`../../team-os/cross-repo-governance.md`](../../team-os/cross-repo-governance.md) | Tier 2 to change |
| Implementation-neutral architecture docs; vendor names live in `profiles/` only | [`../../architecture/profiles/`](../../architecture/profiles/), enforced by [`../../scripts/validate-architecture.sh`](../../scripts/validate-architecture.sh) | Tier 2 to change |
| Reference infrastructure as examples, never as live deployment | [`../../infra/README.md`](../../infra/README.md) | Hard rule — see `SECURITY.md` |
| Coordinated landing for cross-repo changes: pinning, transitive dependencies, deprecation windows, multi-repo completion criteria | [`../../team-os/cross-repo-governance.md`](../../team-os/cross-repo-governance.md) | Tier 2 to change |

## What this repo does NOT promise

| Non-promise | What it means |
|---|---|
| No runtime, no application code, no service implementations | Consumers ship runtime in their own repos; this repo's `infra/` is reference-only |
| No live secrets, no production tfstate, no real account IDs | See [`SECURITY.md`](../../SECURITY.md) and the in-repo scanners; CI fails on any violation |
| No SLA, no incident response, no managed offering | This is the *architecture contract*, not a service. Consumers operate their own deployments |
| No vendor lock-in | Profiles can be added, replaced, or removed without changing the architecture; that's the whole point of the eight-layer model |
| No automatic upgrade for consumers | Consumers pin a ref in `security-first-adoption.md`. Moving to a new ref is itself a Tier 2 change in the consumer |

## Who is on the hook

| Role | Responsibility |
|---|---|
| **Platform team** | Owns this repo. Reviews Tier 2 / Tier 3 changes. Maintains epics, dependency records, the deprecation calendar, the ADR record. |
| **Solution-repo lead** | Owns their consuming repo. Owns their `security-first-adoption.md`. Approves OpenSpec proposals that change their repo's contracts. |
| **Contributor** | Anyone making a change. Opens the right artifact (Tier 1 / Tier 2 / Tier 3), links it from the PR, populates the dependency-record schema fully when applicable. |
| **Reviewer** | Each PR receives review per `.github/CODEOWNERS` and the audience-specific reviewers named in the OpenSpec proposal. |

## Foundational decisions

Three ADRs capture the architecture's load-bearing commitments. Any future change to them is **Tier 3** (cross-repo architecture or security-boundary change) and requires both an OpenSpec proposal AND a new ADR that supersedes:

- [`ADR-0001 — Adopt the eight-layer control model`](../decisions/ADR-0001-adopt-eight-layer-control-model.md)
- [`ADR-0002 — Agents are clients, not insiders`](../decisions/ADR-0002-agents-are-clients-not-insiders.md)
- [`ADR-0003 — Internal identity envelope is the Z4 trust mechanism`](../decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md)

The full ADR index is at [`../decisions/INDEX.md`](../decisions/INDEX.md).

## How consumers adopt

1. **Read the repo contract** at [`../../standards/repo-contract.md`](../../standards/repo-contract.md). It distinguishes the *Universal Floor* (every consumer ships) from *Vendor-Specific Adapters* (only when that tool is used).
2. **Copy the consuming-repo template** from [`../../templates/consuming-repo/`](../../templates/consuming-repo/). Remove any adapter files for tools the team doesn't use.
3. **Fill in `security-first-adoption.md`** — the centerpiece of adoption readiness. It records the architecture-repo ref the consumer pins, the deployment profile, the implemented control layers, any deviations with compensating controls, owners, and the review cadence. Template: [`../../templates/consuming-repo/security-first-adoption.md`](../../templates/consuming-repo/security-first-adoption.md).
4. **Open a dependency record** in this repo's [`../../portfolio/dependencies/`](../../portfolio/dependencies/) declaring the consumer's pinned ref and any Tier 2/3 architecture-repo changes pending integration.
5. **Run the consumer-facing healthchecks** locally inside your repo:
   - `pre-commit run --all-files` (after installing pre-commit hooks following the architecture repo's `.pre-commit-config.yaml` template).
   - The `repo-healthcheck` skill (canonical: `.agents/skills/repo-healthcheck/SKILL.md` in the architecture repo; or via the `/repo-healthcheck` Claude command). This verifies your Universal Floor against the repo contract.
   - **Note:** `scripts/validate-architecture.sh` is the **architecture repo's own** scanner (vendor-neutrality in `architecture/*.md`, `team-os/`, and `standards/`). Consumers do not run it — there is nothing for it to scan in your repo. Consumers run `repo-healthcheck` instead.
6. **Configure CI** to run the three required workflows (`architecture-healthcheck.yml`, `docs-healthcheck.yml`, `skills-healthcheck.yml`) plus this repo's `openspec-triage` and `codeowners-check` if the consumer adopts the OpenSpec policy. Copy or reference these from this repo's `.github/workflows/`.

A worked walkthrough is on the roadmap for the first consumer onboarding (see *Current state* below).

## Current adoption state

| Consumer | Pinned ref | Profile | Owner | Last review |
|---|---|---|---|---|
| [`trupryce`](https://github.com/TruPryce/trupryce) | `v0.1.0` (tag) | `self-hosted-vps` | `@mikegtech` / `@trupryce-platform` | — (first quarterly review due 2026-08-25) |

`trupryce` adopted on **2026-05-25** via [TruPryce/trupryce#4](https://github.com/TruPryce/trupryce/pull/4) (merged 2026-05-27 as `2990364`). Dependency record: [`portfolio/dependencies/2026-05-25-trupryce-depends-on-security-first-platform-architecture-onboarding.md`](../../portfolio/dependencies/2026-05-25-trupryce-depends-on-security-first-platform-architecture-onboarding.md) (`resolved`).

`trupryce` declares all eight control layers as `implemented` *because it is a standalone repo with no parent platform to consume from*. The per-layer maturity is captured by **four recorded deviations** in [`trupryce/security-first-adoption.md`](https://github.com/TruPryce/trupryce/blob/main/security-first-adoption.md) — most notably DEV-002 (service-to-service trust uses a shared-secret header, not the Z4 envelope from [`ADR-0003`](../decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md)). Each deviation has a compensating control and a scheduled remediation.

Future consumers extend this table. The same shape applies whether a consumer is greenfield or migrating a legacy stack — the `deviations:` field is where reality lives.

## Roadmap stance

The repo is in its **scaffold-complete phase**. The architecture, governance, enforcement, and decision records are in place. The next chapter is **consumer adoption**: shipping the first `security-first-adoption.md` in a real consuming repo and exercising every part of the contract end-to-end. Subsequent work (adding profiles, formalizing the envelope claim schema as a versioned spec, growing the policy library) will be driven by real consumer needs rather than speculative completeness.

Anything beyond that is captured (when it exists) in:

- [`../../portfolio/epics/`](../../portfolio/epics/) — multi-repo initiatives
- [`../../openspec/README.md`](../../openspec/README.md) — OpenSpec lifecycle, current proposals (when any are open), and the archive
- [`../decisions/INDEX.md`](../decisions/INDEX.md) — accepted ADRs

## Who to ask

- **Architecture questions** → platform team via the OpenSpec proposal process for Tier 2/3, or a normal issue for Tier 1.
- **Adoption questions** → the consuming repo's `security-first-adoption.md` owner; if that doesn't exist yet, the platform team.
- **Security disclosure** → [`SECURITY.md`](../../SECURITY.md).
- **Audit / compliance** → start at [`../decisions/INDEX.md`](../decisions/INDEX.md) for the rationale record.
