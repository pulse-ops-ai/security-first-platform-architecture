---
name: github-enterprise-ci-review
description: Verify a repo's .github/workflows/ and CODEOWNERS align with the CI/CD standard. Use when onboarding a new consuming repo, when a PR touches .github/workflows/ or CODEOWNERS, or during periodic audits of CI configurations across the workspace.
---

# GitHub Enterprise CI review

<!-- no-shim: claude — vendor-neutral procedure; .claude/commands/github-enterprise-ci-review.md invokes canonical directly. -->
<!-- no-shim: codex -->

Check that a repo's CI/CD baseline matches [`../../../standards/ci-cd-standard.md`](../../../standards/ci-cd-standard.md). Catches drift from the workspace-wide baseline.

## Inputs

- Path to a repository (default: current working directory).

## Definitions

- **Required workflow**: a file in `.github/workflows/` whose filename matches one of `architecture-healthcheck.yml`, `docs-healthcheck.yml`, `skills-healthcheck.yml`. A repo MAY satisfy this by calling a reusable workflow with the same effective behavior, in which case the filename match isn't required but the workflow must invoke the equivalent validator script.
- **Stable job ID**: the value of `jobs.<id>.name` (or the YAML key under `jobs:` if no `name:` is set) must:
  1. Match the regex `^[a-z][a-z0-9-]*$` — lowercase, kebab-case, starts with a letter.
  2. Not change across the PR diff (rename = breaking change for any branch protection rule pinned to that job).
- **Pinned action**: a `uses:` line whose value ends in either a 40-character SHA OR a `vN` / `vN.N` / `vN.N.N` tag. `@main`, `@master`, branch refs, and bare action names without `@` are NOT pinned.

## Procedure

1. **Confirm `.github/workflows/` exists.**

   ```bash
   [[ -d .github/workflows ]] || echo "MISSING .github/workflows/"
   ```

2. **Confirm the three required workflows.**

   ```bash
   for w in architecture-healthcheck.yml docs-healthcheck.yml skills-healthcheck.yml; do
     [[ -f ".github/workflows/$w" ]] && echo "[OK] $w" || echo "[MISSING] $w"
   done
   ```

3. **Confirm each workflow triggers on PR + push-to-main and has stable job IDs.** Run this on every file under `.github/workflows/`:

   ```bash
   for wf in .github/workflows/*.yml; do
     echo "== $wf =="
     grep -qE '^on:|^"on":' "$wf" || echo "  [WARN] no 'on:' trigger declared"
     grep -qE '(pull_request|workflow_call):' "$wf" || echo "  [WARN] no pull_request or workflow_call trigger"
     grep -qE 'push:' "$wf" || echo "  [WARN] no push trigger"

     # Job IDs: extract them and validate the regex.
     awk '/^jobs:/{f=1; next} f && /^  [a-zA-Z0-9_-]+:/{gsub(":",""); print $1; exit_after=0}' "$wf" \
       | while read -r jobid; do
         if [[ ! "$jobid" =~ ^[a-z][a-z0-9-]*$ ]]; then
           echo "  [WARN] job ID '$jobid' is not kebab-case-stable"
         fi
       done
   done
   ```

   For the "doesn't change across the PR diff" criterion:

   ```bash
   git diff origin/main...HEAD .github/workflows/ | \
     grep -E '^[+-]  [a-zA-Z0-9_-]+:' | head -20
   ```

   Any `-old-job-id:` / `+new-job-id:` pair flags a job rename. Branch protection rules pinned to the old name will silently stop blocking — investigate before merge.

4. **Confirm `CODEOWNERS` exists and assigns owners to protected paths.**

   ```bash
   [[ -f .github/CODEOWNERS ]] || echo "[BLOCK] CODEOWNERS missing"
   ```

   For each architecture-affecting path (`/architecture/`, `/team-os/`, `/standards/`, `/templates/`, `/.github/`, `/AGENTS.md`), confirm a CODEOWNERS line covers it:

   ```bash
   for path in /architecture/ /team-os/ /standards/ /templates/ /.github/ /AGENTS.md; do
     if grep -qE "^${path//\//\\/}" .github/CODEOWNERS; then
       echo "[OK]   $path has owners"
     else
       echo "[WARN] $path has no owners"
     fi
   done
   ```

5. **Confirm action pins.** Long-lived deploy credentials and unpinned actions are both supply-chain risks. Grep for unpinned uses:

   ```bash
   grep -rEn '^[[:space:]]*uses:' .github/workflows/ | \
     grep -vE 'uses:[[:space:]]+[^@]+@([0-9a-f]{40}|v[0-9]+(\.[0-9]+){0,2})\b' || echo "(all uses: lines pinned)"
   ```

   Any output here is a `WARN` (third-party actions should pin SHAs; `actions/*` are conventionally pinned to major-version tags and acceptable).

6. **Confirm OIDC for any deploy workflow.** If any workflow has a `permissions: id-token: write` block, that's a positive signal. If a workflow references AWS / GCP / Azure credentials in `secrets.*` without `id-token: write`, that's a `WARN`:

   ```bash
   for wf in .github/workflows/*.yml; do
     if grep -qE 'secrets\.(AWS|AZURE|GCP)_' "$wf" && ! grep -q 'id-token: write' "$wf"; then
       echo "[WARN] $wf uses cloud secrets but does not request OIDC token"
     fi
   done
   ```

## Output

Return:

```
Workflows:
  [OK]      architecture-healthcheck.yml
  [OK]      docs-healthcheck.yml
  [MISSING] skills-healthcheck.yml          ← BLOCK

Triggers and job IDs:
  [OK]      pre-commit.yml — pull_request, push, kebab-case job IDs
  [WARN]    deploy.yml — no push: main trigger

CODEOWNERS:
  [OK]      .github/CODEOWNERS present
  [WARN]    /infra/ has no owners

Action pins:
  (all uses: lines pinned)

OIDC:
  [WARN]    deploy.yml uses secrets.AWS_ACCESS_KEY_ID — consider OIDC federation
```

Plus overall: `PASS` (no findings), `WARN` (warnings only), or `BLOCK` (any missing required workflow or CODEOWNERS).

## Guardrails

- Missing required workflow → `BLOCK`.
- Long-lived cloud credentials → `WARN`, not `BLOCK`, but flagged for the team to migrate to OIDC.
- Renamed job IDs in the diff → `WARN` (branch protection may silently break).
- Do not edit workflows as part of this skill — only report. Fixes come via PRs reviewed by `@ci-owners`.

## See also

- [`../../../standards/ci-cd-standard.md`](../../../standards/ci-cd-standard.md)
- [`../../../team-os/github-enterprise-ci.md`](../../../team-os/github-enterprise-ci.md)
