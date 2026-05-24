# CI/CD Standard

The minimum CI/CD baseline every repo in the workspace must meet, on **GitHub Enterprise**. See [`../team-os/github-enterprise-ci.md`](../team-os/github-enterprise-ci.md) for the operating model.

## Required workflows in every repo

Every repo's `.github/workflows/` must include (or reference reusable workflows equivalent to) the baseline below. The architecture repo ships reusable versions of each via `workflow_call:` — consumers should use thin caller workflows from [`templates/consuming-repo/.github/workflows/`](../templates/consuming-repo/.github/workflows/) rather than vendoring scripts.

### Universal floor (every repo)

| Workflow | What it verifies | Reusable? |
|---|---|---|
| `repo-healthcheck.yml` | Repo follows the security-first platform contract: Universal Floor files (`README.md`, `AGENTS.md`, `LICENSE`, etc.); adoption record (`security-first-adoption.md`) when in consumer mode; Vendor-Specific Adapter consistency (`CLAUDE.md` + `.claude/`, etc.). Auto-detects architecture-repo vs consumer-repo mode via the `standards/repo-contract.md` sentinel. | yes |
| `docs-healthcheck.yml` | Every folder with multiple markdown files has an `INDEX.md`; each `INDEX.md` references existing files; no markdown orphans. | yes |
| `pre-commit.yml` | Runs the repo's `.pre-commit-config.yaml` hooks. Verifies file hygiene, secret-scan baselines, and any consumer-specific lints. | yes |

### Conditional (when the repo exposes the artifact)

| Workflow | When required | What it verifies |
|---|---|---|
| `skills-healthcheck.yml` | The repo has `.agents/skills/` | Every `.agents/skills/<name>/` has a `SKILL.md` with YAML frontmatter and required body sections; `.agents/skills/INDEX.md` lists every skill. |
| `openspec-triage.yml` | The repo participates in cross-repo governance via OpenSpec | Classifies PR diffs by tier; confirms a proposal directory is present for Tier 2/3 changes. |
| `codeowners-check.yml` | The repo enforces required-path ownership | `CODEOWNERS` covers contract-critical paths. |

### Architecture-repo only

| Workflow | What it verifies |
|---|---|
| `architecture-healthcheck.yml` | The architecture repo's own `architecture/` tree stays implementation-neutral (no vendor names leaking outside `architecture/profiles/`). Consumers don't carry an `architecture/` tree, so this check doesn't apply to them. |

The universal-floor three are the **floor**. Repos add language/build/test/deploy workflows on top, plus the conditional workflows when they're applicable.

## Required checks on `main`

- All universal-floor workflows pass (`repo-healthcheck`, `docs-healthcheck`, `pre-commit`).
- All applicable conditional workflows pass (`skills-healthcheck` if the repo has `.agents/skills/`, etc.).
- For Tier 2 / Tier 3 architecture-affecting changes: the `openspec-triage` workflow (`.github/workflows/openspec-triage.yml`, which runs the `openspec-change-triage` skill). Branch protection should require the check named `Tier classification + proposal presence` (the job name) from this workflow.
- Repo-specific test suites at their normal coverage threshold.

## Branch protection (recommended baseline)

- No force-push to `main`.
- Required reviews from a `CODEOWNERS`-listed reviewer.
- Linear history (rebase or squash) — repo discretion.
- All required checks must pass before merge.

## Secrets

- Production secrets are scoped per environment.
- Deploy workflows use OIDC federation (e.g., AWS via GitHub OIDC) — **no** long-lived AWS keys in repo secrets.
- Shared secrets at the org level are scoped to specific repos.

## Runners

- Hosted runners are fine for documentation and validation workflows.
- Self-hosted runners are required when workflows need:
  - access to private networks (the tailnet, internal services), or
  - workload identity from a managed cloud profile.
- Self-hosted runners live in a hardened group; runner tokens are short-lived.

## Reusable workflows

If three or more repos need the same workflow, publish it as a reusable workflow:

- Hosted in this repo (`.github/workflows/`) or a dedicated tooling repo.
- Versioned via Git ref (tag or SHA).
- Documented inputs at the top of the file.

## What this standard does NOT mandate

- Specific test runners or coverage thresholds.
- Specific deploy targets.
- Specific PR templates (recommended, not required).

## Anti-patterns

- **Healthchecks that always pass.** A check that never finds a problem is decorative.
- **Long-lived deploy credentials.** Use OIDC.
- **Per-repo bespoke healthchecks.** Use the shared validation scripts in [`../scripts/`](../scripts/) where possible.
