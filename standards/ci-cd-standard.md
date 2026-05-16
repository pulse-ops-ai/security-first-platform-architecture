# CI/CD Standard

The minimum CI/CD baseline every repo in the workspace must meet, on **GitHub Enterprise**. See [`../team-os/github-enterprise-ci.md`](../team-os/github-enterprise-ci.md) for the operating model.

## Required workflows in every repo

Every repo's `.github/workflows/` must include (or reference reusable workflows equivalent to) these three:

| Workflow | What it verifies |
|---|---|
| `architecture-healthcheck.yml` | Repo declares its target profile; metadata is consistent with the architecture standard; no vendor names leaking into vendor-neutral docs. |
| `docs-healthcheck.yml` | `docs/INDEX.md` exists; every `.md` under `docs/` is referenced by an index; broken intra-repo links flagged. |
| `skills-healthcheck.yml` | Every `.agents/skills/<name>/` has a `SKILL.md` with YAML frontmatter and required body sections; `.agents/skills/INDEX.md` lists every skill. |

These three are the **floor**. Repos add language/build/test/deploy workflows on top.

## Required checks on `main`

- All three healthchecks pass.
- For Tier 2 / Tier 3 architecture-affecting changes: `openspec-change-triage` check.
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
