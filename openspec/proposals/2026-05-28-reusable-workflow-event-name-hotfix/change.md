# OpenSpec Change: Reusable-workflow event-name guard hotfix

Companion to [`proposal.md`](proposal.md).

## Files modified

### `.github/workflows/docs-healthcheck.yml`

Two diff hunks:

**Step *"Checkout architecture repo for scripts (consumer call only)"*:**

- Before: `if: github.event_name == 'workflow_call'`
- After: `if: inputs.architecture_ref != ''`
- Comment block above the `if:` rewritten to document **why** the `inputs` discriminator is correct and `github.event_name` is wrong, with an explicit warning *"Do NOT gate on `github.event_name == 'workflow_call'`"* citing the PR #14 round-4 regression.

**Step *"Determine script path"* (bash body):**

- Before: `if [[ "${{ github.event_name }}" == 'workflow_call' ]]; then`
- After: `if [[ -n "${{ inputs.architecture_ref }}" ]]; then`
- Inline comment above the `run:` block rewritten to anchor to the new discriminator.

### `.github/workflows/repo-healthcheck.yml`

Identical pair of changes (same step names, same discriminator, same comment updates).

### Files added

- `openspec/proposals/2026-05-28-reusable-workflow-event-name-hotfix/{proposal,change,tasks}.md` — this proposal.

### Files NOT modified

- `.github/workflows/pre-commit.yml` — has no dual-checkout step, no `architecture_ref` input usage, not affected by the bug.
- `templates/consuming-repo/.github/workflows/*.yml` — thin callers are correct as-is; they pass `architecture_ref` correctly.
- `templates/consuming-repo/.pre-commit-config.yaml` — unaffected.
- `scripts/repo-healthcheck.sh`, `scripts/validate-doc-indexes.sh` — unaffected; the scripts themselves were never the problem.
- `standards/ci-cd-standard.md`, `standards/repo-contract.md` — unaffected; no contract change.

## Contract changes

**No contract changes.** This is a bug revert restoring PR #14 round-3 behaviour:

- `workflow_call` input shape: unchanged (`architecture_ref: required: true, type: string`).
- Self-mode behaviour: unchanged (still uses caller's own `scripts/...`).
- Consumer-mode behaviour: restored to working (was always intended; broken by round-4).
- No-fallback policy: unchanged (consumer mode MUST use `.arch-tools/scripts/...`; no fallback to caller `scripts/`).
- Mode-strict script selection: unchanged in intent; just driven by the correct discriminator now.

## Cross-repo migration steps

After this PR merges:

1. **Tag `v0.1.1`** on `main`. Release notes cite the bug, the cause, and the fix.
2. **Tiny housekeeping PR** in the architecture repo: bump `portfolio/dependencies/2026-05-24-platform-edge-depends-on-security-first-platform-architecture-onboarding.md` `upstream_ref:` from `v0.1.0` → `v0.1.1`. One line.
3. **`platform-edge`** repins:
   - `security-first-adoption.md` `architecture_ref:` `v0.1.0` → `v0.1.1` (and `architecture_ref_kind: tag` stays).
   - `.github/workflows/{repo-healthcheck,docs-healthcheck,pre-commit}.yml` `@ref` lines: `@v0.1.0` → `@v0.1.1` (six edits total — `uses:` and `with: architecture_ref:` per workflow, modulo `pre-commit.yml` which only has `uses:`).
   - Push to the open step-1 PR. CI should turn green.
4. **`trupryce`** does nothing. Its adoption record points at `v0.1.0` and is `resolved`. The fix is available when trupryce next has reason to bump.

## Rollback

If the fix itself introduces a regression (e.g., `inputs.architecture_ref != ''` somehow fires in self-mode), the revert is trivial: drop both modified steps back to PR #14 round-3 (commit `7dfeaa4`). That is in fact what this PR is doing — restoring round-3. There is no further-back state to revert to.

## Verification

- `bash scripts/sync-agent-skills.sh --check`: PASS (workflow files do not affect skill validation).
- `bash scripts/validate-skills.sh`: PASS.
- `bash scripts/validate-doc-indexes.sh`: PASS.
- `bash scripts/repo-healthcheck.sh`: PASS.
- `pre-commit run --all-files`: 19/19 PASS.
- `openspec-triage.sh origin/main`: Tier 2 with proposal present.
- **Self-mode CI on this PR**: this PR's own CI is the smoke test for self-mode — `inputs.architecture_ref` evaluates to empty in self-mode, both modified steps must behave correctly. If self-mode CI passes on this PR, the self-mode path is validated.
- **Consumer-mode CI**: validated by `platform-edge`'s step-1 PR turning green after repinning to `v0.1.1`. This is the real-world consumer-mode test the architecture repo cannot self-administer.
