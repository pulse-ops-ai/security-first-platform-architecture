# OpenSpec Change: Enforcement and Skill Rigor

Companion to [`proposal.md`](proposal.md). This file describes the concrete diffs.

## Files added

### Scripts

- `scripts/check-network-as-identity.sh` — heuristic scanner with 5 categories: `ip-as-identity`, `internal-cidr-trust`, `mesh-only-identity`, `fail-open`, `long-lived-cred`. Output masks suspected credential values.
- `scripts/check-infra-secrets.sh` — scans `infra/` for 12-digit AWS account IDs (excluding documented placeholders like `123456789012`), real ARNs with account-ID segments, and hard-coded region defaults in non-example files.
- `scripts/openspec-triage.sh` — diffs against a base ref, classifies each touched file Tier 1/2/3, requires a proposal directory for Tier 2/3, validates `proposal.md` and `tasks.md` frontmatter (`tier`, `completion_state`). Blocks Tier 3 + `architecture-complete` combo.

### Workflows

- `.github/workflows/openspec-triage.yml` — triggers on PRs touching architecture / standards / templates / skills / CI / AGENTS / OpenSpec paths. Resolves base SHA, runs `openspec-triage.sh`.
- `.github/workflows/codeowners-check.yml` — pinned `mszostok/codeowners-validator@v0.7.4` for syntax. Custom step verifies required-path coverage. Placeholder owners reported as WARN only.
- `.github/workflows/pre-commit-autoupdate.yml` — scheduled weekly (Mon 08:17 UTC). Runs `pre-commit autoupdate`, runs full hook chain, opens a PR via `peter-evans/create-pull-request@v6` only if changes are present AND hooks pass.

### Config

- `.github/dependabot.yml` — github-actions ecosystem only, weekly, minor+patch grouped.

### OpenSpec entrypoint

- `openspec/README.md` — repo-local OpenSpec entrypoint per the floor requirement.
- `openspec/proposals/2026-05-16-enforcement-and-skill-rigor/` — this proposal.

## Files modified

### Skills (rewritten with concrete procedures)

- `.agents/skills/architecture-review/SKILL.md` — calls `bash scripts/validate-architecture.sh`; defines layer-assignment checklist; adds bucketing rules for the diff.
- `.agents/skills/security-control-review/SKILL.md` — calls `bash scripts/check-network-as-identity.sh .`; documents the 5 finding categories and their typical false-positive sources.
- `.agents/skills/cross-repo-impact-review/SKILL.md` — enumerates sibling repos (trupryce, findevil, levelup-platform, splunk-agentic-ops) with exact discovery and ripgrep commands; cross-references `security-first-adoption.md` field names.
- `.agents/skills/github-enterprise-ci-review/SKILL.md` — defines "stable job ID" precisely (regex `^[a-z][a-z0-9-]*$` + unchanged across diff); adds concrete commands for triggers, action pinning, and OIDC checks.
- `.agents/skills/openspec-change-triage/SKILL.md` — calls `bash scripts/openspec-triage.sh origin/main`; cross-references `cross-repo-impact-review` for the dep-record-per-consumer check that this skill does NOT cover.

### Architecture

- `architecture/deployment-profiles.md` — added `## Compensating controls` section defining required fields (`id`, `layer`, `gap`, `control`, `evidence`, `monitoring`, `expires`, `accepted_by`) and three anti-patterns. Closes review finding S6.

### Config

- `.pre-commit-config.yaml` — added `check-infra-secrets` local hook scoped to `^infra/`.

### Docs

- `scripts/README.md` — added rows for `check-infra-secrets.sh`, `check-network-as-identity.sh`, `openspec-triage.sh` plus their local-run commands.

## Contract changes

None. This PR adds machinery to enforce existing contracts (from PR-2) but does not change any contract surface.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. No consumer must act.

## Rollback

Each change is independently revertable:

- Workflows: delete the `.yml` file; the gate disappears.
- Scripts: delete the file; any skill or hook referencing it will fail until the reference is updated.
- Skill rewrites: revert the specific `SKILL.md`; the previous prose version is in PR-2's merged history.
- `.pre-commit-config.yaml` hook: remove the `check-infra-secrets` block.
- Compensating-controls section: remove it; profiles continue without the explicit format (they have to date).

No rollback is irreversible. There are no data migrations.

## Verification

- `pre-commit run --all-files` passes (now includes `check-infra-secrets`).
- All four pre-existing validators (`validate-architecture.sh`, `validate-doc-indexes.sh`, `validate-skills.sh`, `sync-agent-skills.sh --check`) continue to pass.
- The three new scanners (`check-network-as-identity.sh`, `check-infra-secrets.sh`, `openspec-triage.sh`) all exit `0` against the current repo state.
- `openspec-triage.sh` correctly identifies this PR as Tier 2 and finds the proposal directory in the diff. _Sanity tested against a synthetic Tier 2 diff: blocks correctly when no proposal is present; passes when one is._
