# OpenSpec Change: Template completeness + workflow portability

Companion to [`proposal.md`](proposal.md).

## Files added

### Consumer template — workflows, configs, adapter shims

- `templates/consuming-repo/.github/workflows/repo-healthcheck.yml` — thin caller for the reusable workflow; uses `__ARCHITECTURE_REF__` placeholder.
- `templates/consuming-repo/.github/workflows/docs-healthcheck.yml` — same shape.
- `templates/consuming-repo/.github/workflows/pre-commit.yml` — same shape (no `architecture_ref` input needed; pre-commit is generic).
- `templates/consuming-repo/.github/CODEOWNERS` — placeholder with `@<solution-team>` / `@<consumer-lead>` substitution markers; rows per Universal Floor + Vendor-Specific Adapter paths.
- `templates/consuming-repo/.pre-commit-config.yaml` — consumer-portable hook chain. INCLUDES: pre-commit-hooks (file hygiene), shellcheck, gitleaks, detect-secrets. EXCLUDES: any architecture-repo-specific scripts (validate-skills, sync-agent-skills, validate-architecture, check-infra-secrets, check-inline-secrets, openspec-triage, repo-healthcheck).
- `templates/consuming-repo/.secrets.baseline` — empty starting baseline; consumer regenerates after first scan.
- `templates/consuming-repo/.gitleaks.toml` — same narrow allowlist as the architecture repo's (excludes `.secrets.baseline` from gitleaks scan; the hashed_secret hex tripped the generic-api-key rule).
- `templates/consuming-repo/.claude/skills/README.md` — adapter shim directory README.
- `templates/consuming-repo/.claude/commands/README.md` — slash-command directory README, including a recommended list of architecture-repo skills useful from a consumer context.
- `templates/consuming-repo/.claude/agents/README.md` — sub-agent directory README.

### Architecture repo — new workflow

- `.github/workflows/repo-healthcheck.yml` — runs `scripts/repo-healthcheck.sh` against this repo (architecture-repo mode); also has `workflow_call:` trigger for consumers.

### OpenSpec

- `openspec/proposals/2026-05-17-template-completeness-and-workflow-portability/{proposal,change,tasks}.md` — this proposal.

## Files modified

### Architecture repo — workflow refactor

- `.github/workflows/docs-healthcheck.yml` — adds `workflow_call:` trigger with optional `architecture_ref` input. New conditional step that does sparse-checkout of architecture repo's `scripts/` when invoked from a consumer. Determines script path based on whether `.arch-tools/` is present. Calls `validate-doc-indexes.sh` with `.` as the target.
- `.github/workflows/pre-commit.yml` — adds `workflow_call:` trigger (no inputs); rest unchanged.

### Architecture repo — script refactor

- `scripts/validate-doc-indexes.sh` — accepts an optional target path argument; defaults to the script's own repo root when not supplied. Lets the reusable workflow run the script against the caller's tree.

### Standards + runbook

- `standards/repo-contract.md` — new "What the consumer template ships" section listing the full template tree and explaining the reusable-workflow contract. Minor wording fix to "What this contract does NOT mandate" to reference `ci-cd-standard.md` consistently with the updated baseline.
- `standards/ci-cd-standard.md` — restructured §Required workflows in every repo into Universal floor / Conditional / Architecture-repo-only tiers. `repo-healthcheck.yml` (introduced in PR #13) replaces `architecture-healthcheck.yml` as the universal floor; `architecture-healthcheck.yml` is now correctly scoped to the architecture repo. `pre-commit.yml` added to the floor; `skills-healthcheck.yml` made conditional ("required if the repo has `.agents/skills/`"). §Required checks on `main` updated to match.
- `docs/operations/first-consumer-onboarding.md`:
  - Step 2's bash block: removed the workflow-copy sub-step and the pre-commit/secrets-baseline sub-step (template now has them). Kept the adapter-removal sub-step.
  - The "you should now have these files" list updated with the full template contents and an `__ARCHITECTURE_REF__` substitution callout.
  - Step 3: new `sed` invocation that substitutes the pinned ref into all three workflow files.
  - Step 9: reframed from "configure your CI" to "confirm your CI is wired correctly." No script-copying or workflow-authoring remaining.

### OpenSpec lifecycle

- `openspec/proposals/2026-05-17-repo-healthcheck-alignment/` → `openspec/archive/2026-05-17-repo-healthcheck-alignment/` (PR #13's proposal, merged 2026-05-17). Frontmatter `status: in_review` → `accepted`; added `accepted_date`, `archived_date`, `merged_pr: 13`.
- `openspec/README.md` — current/archived proposal lists updated.

## Contract changes

**One new mechanical contract:** the **reusable-workflow `@ref` pinning rule** between architecture repo and consumers. A consumer's `.github/workflows/*.yml` carries `uses: pulse-ops-ai/security-first-platform-architecture/.github/workflows/<name>.yml@<ref>` where `<ref>` MUST match the consumer's `security-first-adoption.md` `architecture_ref:`. This is enforced by the runbook (step 3 substitution) and surfaced in the new repo-contract section; eventually a script could automatically verify the match.

No other contracts change. No control-layer or security-boundary impact.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. trupryce (next, in trupryce's repo) is the first user of both the completed template and the reusable workflows; their onboarding PR is the de-facto integration test.

## Rollback

Each piece is independently revertible:

- Revert script refactor → workflows still work in self-mode (script ignores extra arg if not passed).
- Revert workflow `workflow_call:` additions → architecture-repo CI unaffected; consumer template workflows would fail (no reusable available).
- Delete template files → adopters fall back to PR #12's onboarding runbook with the workflow-copy sub-step (which we documented as a known gap).
- Move PR #13 proposal back to `proposals/` → undoes archive.

No rollback is irreversible.

## Verification

- `bash scripts/validate-doc-indexes.sh` (no args): PASS (self-mode).
- `bash scripts/validate-doc-indexes.sh .` (explicit path): PASS (same result).
- `bash scripts/repo-healthcheck.sh`: PASS (architecture-repo mode).
- All pre-existing validators PASS.
- `openspec-triage.sh origin/main`: Tier 2 with proposal present.
- `pre-commit run --all-files`: 19 hooks PASS.
- Template completeness: `find templates/consuming-repo -type f | wc -l` returns the new file count (≥15).
- Workflow YAML validity: `check-yaml` passes on all four new template workflows.
