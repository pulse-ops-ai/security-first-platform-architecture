# Branch protection — operational runbook

Branch protection lives in **GitHub repo settings**, not in code. This runbook documents the desired state and the `gh api` commands to apply or audit it. It is intentionally not enforced from a workflow — the workflow that *could* enforce it would itself need a token capable of changing branch protection, which is a security concession we are not making.

## Desired state for `main`

| Rule | Value | Why |
|---|---|---|
| Require pull request before merging | **on** | No direct pushes; every change is reviewable. |
| Require approvals | **1** minimum | Tier 2/3 changes get more reviewers via CODEOWNERS; this is the floor. |
| Dismiss stale approvals on new commits | **on** | Prevents an old approval from carrying through new commits. |
| Require review from Code Owners | **on** | Pairs with `.github/CODEOWNERS`. |
| Require status checks to pass before merging | **on** | See list below. |
| Require branches to be up to date before merging | **on** | Forces conflict resolution before merge. |
| Require conversation resolution before merging | **on** | No silently-merged unresolved comments. |
| Require signed commits | **off** (for now) | Revisit when the team has a key-management story. |
| Require linear history | **on** | Squash-merge or rebase-merge only; cleaner history. |
| Include administrators | **on** | Admins follow the same rules. |
| Allow force pushes | **off** | History on `main` is append-only. |
| Allow deletions | **off** | The `main` branch is not deletable. |

### Required status checks

In order, the contexts pinned for `main`:

1. `pre-commit / pre-commit run --all-files`
2. `architecture-healthcheck / Architecture documents present and implementation-neutral`
3. `docs-healthcheck / Doc indexes are in sync`
4. `skills-healthcheck / Skills follow the SKILL.md standard and stay in sync`
5. `openspec-triage / Tier classification + proposal presence`
6. `codeowners-check / CODEOWNERS syntax and required coverage`

If any of these context names change in a workflow, branch protection silently stops blocking on the old context. The `github-enterprise-ci-review` skill flags job-ID renames in the diff for exactly this reason — but the operator still has to re-pin the protection rule.

## Applying the desired state

> Requires a GitHub Enterprise token with `repo` + `admin:repo_hook` scope. **Do not** check in the token; pass it via `GH_TOKEN`.

```bash
gh api -X PUT \
  "repos/pulse-ops-ai/security-first-platform-architecture/branches/main/protection" \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "pre-commit / pre-commit run --all-files",
      "architecture-healthcheck / Architecture documents present and implementation-neutral",
      "docs-healthcheck / Doc indexes are in sync",
      "skills-healthcheck / Skills follow the SKILL.md standard and stay in sync",
      "openspec-triage / Tier classification + proposal presence",
      "codeowners-check / CODEOWNERS syntax and required coverage"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "required_signatures": false
}
EOF
```

## Auditing the current state

```bash
gh api "repos/pulse-ops-ai/security-first-platform-architecture/branches/main/protection" \
  | jq '{
      required_status_checks: .required_status_checks.contexts,
      strict: .required_status_checks.strict,
      enforce_admins: .enforce_admins.enabled,
      pr_review: {
        dismiss_stale: .required_pull_request_reviews.dismiss_stale_reviews,
        codeowners: .required_pull_request_reviews.require_code_owner_reviews,
        approvals: .required_pull_request_reviews.required_approving_review_count
      },
      linear_history: .required_linear_history.enabled,
      force_pushes: .allow_force_pushes.enabled,
      conversation_resolution: .required_conversation_resolution.enabled
    }'
```

Diff the output against the table above. Any drift is an ops finding.

## Reviewing protection state

Branch protection is reviewed at the same cadence as the platform team's quarterly architecture review. Document any deliberate deviation from the table above in this file and link the ADR that justifies it.

## Why this isn't code-enforced

Three reasons:

1. **Trust boundary.** A workflow that can change branch protection can also remove branch protection. That trust level is operator-only.
2. **One-way operation.** Branch protection is set, not continuously reconciled. Drift between desired and actual is rare and surfaces via this audit command — no point spending CI minutes polling.
3. **Operational artifact.** The desired state lives in this file (versioned, reviewable, auditable). The applied state lives in GitHub. The split is acceptable because both are visible to anyone who looks.

If the team later decides to enforce this from code (e.g., via a Terraform provider managing GitHub repos), the desired state in this file becomes the input.
