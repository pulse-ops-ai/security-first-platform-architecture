# GitHub Enterprise CI/CD

The workspace uses **GitHub Enterprise** for source hosting and CI/CD. This document describes the model — not the configuration of any single workflow.

## Principles

1. **Same CI shape in every repo.** Consuming repos run a small, predictable set of workflows (healthchecks, doc checks, OpenSpec checks, plus repo-specific build/test).
2. **Required checks are minimal but real.** Every PR must demonstrably pass the structural and architectural checks before merge.
3. **Architecture repo does not run application CI.** Its CI validates documents, indexes, skills, and the repo contract.
4. **Workflows live in `.github/workflows/` in each repo.** Reusable workflows can be referenced via path or by published reusable workflow.

## Required workflows in every repo

| Workflow | Purpose |
|---|---|
| `architecture-healthcheck.yml` | Verify the repo declares which architecture version / profile it follows and that core architecture rules are not violated by repo metadata. |
| `docs-healthcheck.yml` | Verify `docs/INDEX.md` exists and references existing files. |
| `skills-healthcheck.yml` | Verify each `.agents/skills/<name>/` directory has a `SKILL.md` with the required frontmatter and sections, and that `.agents/skills/INDEX.md` lists every skill. |

These three are the minimum. Consuming repos add their own build/test/deploy workflows on top.

## Naming conventions

- Workflow filenames are kebab-case and describe behavior, not tool (`docs-healthcheck.yml`, not `lint.yml`).
- Jobs and steps have stable IDs so branch protection rules can be set on them.

## Branch protection (recommended baseline)

- `main` requires the three healthchecks to pass.
- Tier 2 / Tier 3 changes to the architecture repo additionally require an `openspec-change-triage` check.
- Force pushes to `main` disabled. Linear history required if the team prefers.

## Secrets and runners

- GitHub Enterprise secrets are scoped per repo by default; shared secrets (e.g., observability API tokens) live in org-level secret stores with scoped access.
- Self-hosted runners (if used) live in a hardened security group, on the AWS-managed or hybrid profile per [`../architecture/profiles/`](../architecture/profiles/).
- Runners do not have implicit production credentials. Deploys use OIDC federation, not long-lived secrets.

## Reusable workflows

If the same workflow shape recurs across consuming repos, publish it as a reusable workflow in the architecture repo or a dedicated tooling repo. Reusable workflows must:

- Be vendor-neutral where possible.
- Document inputs in the workflow file.
- Be versioned (Git ref) so consumers can pin.

## What this repo's own CI does

See [`../.github/workflows/`](../.github/workflows/). At minimum:

- `architecture-healthcheck.yml`
- `docs-healthcheck.yml`
- `skills-healthcheck.yml`

These are intentionally lightweight scaffolds. The validation scripts they call live in [`../scripts/`](../scripts/) and can be extended over time.
