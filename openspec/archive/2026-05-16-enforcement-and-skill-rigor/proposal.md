---
tier: 2
status: accepted
completion_state: architecture-complete
opened: 2026-05-16
target_decision_date: 2026-05-23
accepted_date: 2026-05-16
archived_date: 2026-05-16
merged_pr: 3
authors:
  - "@mike"
---

# OpenSpec Proposal: Enforcement and Skill Rigor

## Problem

PR-1 and PR-2 built the architecture, TeamOS, and adoption contract. Both PRs intentionally deferred the **enforcement** layer that turns the policies into CI gates and the **skill rigor** that turns the cross-repo review SKILL.md files from prose into executable procedures.

Concretely, after PR-2 we have:

- `team-os/openspec-policy.md` defines three tiers, but no CI workflow classifies PRs or blocks Tier 2/3 changes that lack a proposal.
- `cross-repo-governance.md` defines dep-record-per-consumer, but no CI enforces it.
- Four cross-repo review skills (`architecture-review`, `security-control-review`, `cross-repo-impact-review`, `github-enterprise-ci-review`) are written as prose procedures rather than executable scripts. An agent invoking them has to invent the grep patterns.
- `infra/` is reference-only by policy, but nothing scans for the specific shapes (12-digit AWS account IDs, real ARNs, region defaults) that should never appear.
- `.github/CODEOWNERS` is hand-rolled with placeholder owners; nothing checks that path coverage is intact or that owners resolve.
- `.pre-commit-config.yaml` revisions will go stale without an automated bump mechanism.

This is a Tier 2 change because it modifies CI gates, skills, the pre-commit config, and a refined architecture section ("compensating controls"). It does not modify the eight-layer model, the agent-as-client rule, the envelope schema, or any other Tier 3 surface.

## Proposed change

Ship six tightly-scoped enforcement and rigor additions:

1. **Network-as-identity scanner** (`scripts/check-network-as-identity.sh`) — heuristic source-tree scanner for client-IP-as-identity, internal-CIDR-trust, mesh-only identity, fail-open authz, and long-lived credential smells. Invoked by `security-control-review` skill.
2. **OpenSpec triage** (`scripts/openspec-triage.sh` + `.github/workflows/openspec-triage.yml`) — classifies a PR diff into Tier 1/2/3 per the policy; verifies proposal presence and frontmatter for Tier 2/3.
3. **CODEOWNERS validation** (`.github/workflows/codeowners-check.yml`) — pinned `mszostok/codeowners-validator` for syntax; custom step for required-path coverage; placeholder owners listed as WARN.
4. **infra account-ID scanner** (`scripts/check-infra-secrets.sh`) — catches 12-digit AWS account IDs, real ARNs, hard-coded region defaults; wired into pre-commit.
5. **Dependabot + autoupdate** (`.github/dependabot.yml` + `.github/workflows/pre-commit-autoupdate.yml`) — weekly bumps for github-actions ecosystem; weekly pre-commit autoupdate that opens a PR.
6. **Skill rewrites** — `architecture-review`, `security-control-review`, `cross-repo-impact-review`, `github-enterprise-ci-review`, and `openspec-change-triage` SKILL.md files rewritten to call the new/existing scripts with concrete commands, definitions, and output shapes.

Plus a refinement: define **compensating controls** in `architecture/deployment-profiles.md` with required fields and anti-patterns. This closes review finding S6.

## Alternatives considered

- **Defer enforcement entirely; treat SKILL.md prose as sufficient.** Rejected. The policies in PR-2 are unenforceable today; the longer they stay unenforced, the more drift accumulates before the first real violation.
- **One large script that does all six checks.** Rejected. Each script has a distinct trigger (pre-commit hook vs CI workflow vs skill invocation) and the failures should be independently understandable. Splitting also lets us evolve each scanner without touching the others.
- **Build OpenSpec triage as a custom GitHub App.** Rejected. A bash script + workflow is portable to GitHub Enterprise and self-hosted runners. An App adds operational burden disproportionate to the value.
- **Use a community network-as-identity linter (e.g., semgrep rules).** Considered. semgrep is more accurate but introduces a Python dependency in CI and a third-party rule set that needs maintenance. The heuristic bash script is good enough for the scaffold phase; revisit when the false-positive rate becomes the bottleneck.

## Impact

- **Repos affected:** the architecture repo itself. **No consuming repos are affected** by this PR — the new scripts and workflows live entirely in the architecture repo. Consumers will see the policies enforced when they next pull a new architecture ref, but their existing `security-first-adoption.md` records remain valid.
- **Layers / profiles affected:** none. This is governance machinery, not control-layer content.
- **Standards affected:** none (the standards prose was completed in PR-2; this PR only adds the enforcement of those standards).
- **Templates affected:** none.
- **Cross-repo contracts:** none.
- **Security-boundary impact:** none directly. The new `check-network-as-identity.sh` and `check-infra-secrets.sh` scanners *help reviewers find* boundary violations, but they do not change which crossings are allowed.

## Affected consumers (Tier 2/3 only)

| Consumer repo | Affected artifact | Dependency record | Owner |
|---|---|---|---|
| _(none — no consumer-facing artifact changes)_ | n/a | n/a | n/a |

This PR is `completion_state: architecture-complete` because no consumer must take action. The new CI checks apply to the architecture repo only.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a` (no consumer coordination needed)
- **`deprecation_window:`** `n/a` (no pattern is superseded)
- **Migration steps:** none required for consumers. For the architecture-repo maintainers:
  1. Merge this PR.
  2. Confirm the new workflows pass on `main`.
  3. The first subsequent PR that touches architecture/standards/templates/AGENTS.md will trigger `openspec-triage.yml` — verify the workflow gates correctly.

## Completion criteria

`completion_state: architecture-complete`

- All architecture-side tasks resolved.
- Healthcheck + openspec-triage + codeowners-check workflows green on `main` after merge.
- No ADR required (Tier 2).

## Approval

- **Required reviewers:** platform team (this PR has no consumer impact, so no consumer leads required).
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete change spec
- [`tasks.md`](tasks.md) — execution plan
- No ADRs (Tier 2, no architectural trade-off captured)
- No dependency records (no consumer impact)
