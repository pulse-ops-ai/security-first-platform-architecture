---
name: github-enterprise-ci-review
description: Verify a repo's .github/workflows/ and CODEOWNERS align with the CI/CD standard. Use when onboarding a new consuming repo, when a PR touches .github/ files, or during periodic audits of CI configurations across the workspace.
---

# GitHub Enterprise CI review

Check that a repo's CI/CD baseline (workflows, CODEOWNERS, secrets handling) matches [`../../../standards/ci-cd-standard.md`](../../../standards/ci-cd-standard.md). Catches drift from the workspace-wide baseline.

## Inputs

- Path to a repository (default: current working directory).

## Procedure

1. Confirm `.github/workflows/` exists.
2. Confirm the three required workflows are present (directly or via reusable workflow reference):
   - `architecture-healthcheck.yml`
   - `docs-healthcheck.yml`
   - `skills-healthcheck.yml`
3. Confirm each workflow has at least one job, runs on `pull_request` and `push: main`, and has stable job IDs.
4. Confirm `CODEOWNERS` exists at the repo root and assigns reviewers to architecture-affecting paths.
5. Confirm deploy workflows (if any) do not use long-lived cloud credentials — prefer OIDC federation.
6. Record findings.

## Output

Return:

```
Workflows:
  [OK]      architecture-healthcheck.yml
  [OK]      docs-healthcheck.yml
  [MISSING] skills-healthcheck.yml

CODEOWNERS:
  [OK]      present
  [WARN]    no owner for architecture/

Secrets:
  [WARN]    deploy.yml uses repo secret AWS_ACCESS_KEY_ID (consider OIDC)
```

Plus overall: `PASS`, `WARN`, or `BLOCK`.

## Guardrails

- Missing required workflow → `BLOCK`.
- Long-lived cloud credentials → `WARN`, not `BLOCK`, but flagged for the team to migrate to OIDC.
- Do not edit workflows as part of this skill — only report. Fixes come via PRs reviewed by `@ci-owners`.

## See also

- [`../../../standards/ci-cd-standard.md`](../../../standards/ci-cd-standard.md)
- [`../../../team-os/github-enterprise-ci.md`](../../../team-os/github-enterprise-ci.md)
