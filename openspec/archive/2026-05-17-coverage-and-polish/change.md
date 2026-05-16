# OpenSpec Change: Coverage Closure and Polish

Companion to [`proposal.md`](proposal.md). Two items added during PR-8 review are marked **(added in review)** below.

## Files added

### Claude slash commands (`.claude/commands/`)

- `architecture-review.md`
- `security-control-review.md`
- `cross-repo-impact-review.md`
- `github-enterprise-ci-review.md`
- `openspec-change-triage.md`
- `architecture-decision-record.md`
- `repo-healthcheck.md`
- `doc-spine-sync.md`

Each command file has a short prose body invoking the canonical SKILL.md and (where applicable) `$ARGUMENTS` substitution. Where the underlying script doesn't support a path argument, the command is scoped to "current repo only" with explicit `cd` guidance in the body **(adjusted in review)**.

### Commit-msg hook

- `scripts/check-commit-message.sh` — enforces conventional-commits prefix on the first non-blank, non-comment line of the commit message. Allows `Merge ...` and `Revert "..."` commits. Allowed prefixes: `chore`, `feat`, `fix`, `docs`, `refactor`, `test`, `style`, `perf`, `ci`, `build`, `revert`, `openspec`.

### Branch-protection runbook

- `docs/operations/branch-protection.md` — desired state table, `gh api PUT` invocation to apply, `gh api GET` invocation to audit, explicit reasoning for why this isn't code-enforced.

### This proposal

- `openspec/proposals/2026-05-17-coverage-and-polish/{proposal,change,tasks}.md`

## Files modified

### Canonical skill bodies (8 files)

Added `<!-- no-shim: claude -->` and `<!-- no-shim: codex -->` markers right after the `# Title` line in each:

- `.agents/skills/architecture-review/SKILL.md`
- `.agents/skills/security-control-review/SKILL.md`
- `.agents/skills/cross-repo-impact-review/SKILL.md`
- `.agents/skills/github-enterprise-ci-review/SKILL.md`
- `.agents/skills/openspec-change-triage/SKILL.md`
- `.agents/skills/architecture-decision-record/SKILL.md`
- `.agents/skills/repo-healthcheck/SKILL.md`
- `.agents/skills/doc-spine-sync/SKILL.md`

The markers are HTML comments so they don't render in the doc body but the validator's substring grep matches them.

### CI gates

- `scripts/openspec-triage.sh` — `is_tier2_file()` updated: `scripts/*.md` and `scripts/*.txt` are Tier 1; `scripts/*.sh` / `*.py` / `*.rb` / `*.js` / `*.ts` are Tier 2; unknown extensions under `scripts/` default to Tier 2 (safer toward over-classification). **Plus, added in review:** Dependabot actor exemption — when `GITHUB_ACTOR == 'dependabot[bot]'`, classify as Tier 1 unconditionally.
- `scripts/validate-doc-indexes.sh` **(added in review)** — extended to emit `[BROKEN]` (relative link in `INDEX.md` resolves to a missing file) and `[ORPHAN]` (subdirectory has its own `INDEX.md` but the parent doesn't link to it) findings, alongside the existing `[UNLISTED]` finding. Closes the spec/implementation gap with the `doc-spine-sync` canonical skill.
- `.pre-commit-config.yaml` — added `check-commit-message` hook on the `commit-msg` stage. The hook receives the message file path as `$1`.

### Indexes / docs

- `.claude/commands/README.md` — lists all 10 commands grouped by purpose; adds a "Pattern" section explaining why these skills carry `no-shim: claude` markers.
- `docs/operations/INDEX.md` — links the new branch-protection runbook.
- `openspec/README.md` — moves the first proposal entry to a new `## Archived proposals` section; adds the PR-4 proposal under `## Current proposals`.

## Files moved

- `openspec/proposals/2026-05-16-enforcement-and-skill-rigor/` → `openspec/archive/2026-05-16-enforcement-and-skill-rigor/`
- Frontmatter updated: `status: in_review` → `status: accepted`. Added `accepted_date: 2026-05-16`, `archived_date: 2026-05-16`, `merged_pr: 3`.

## Contract changes

None. This PR adds adapter files, enforcement polish, and operational docs. No control-layer, profile, standard, template, or cross-repo contract is modified.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. Consumers see the new slash commands when they pull this architecture-repo ref, but their use is opt-in.

## Rollback

Each change is independently revertible:

- Delete a `.claude/commands/<name>.md` to remove a slash command.
- Remove the HTML-comment markers from a SKILL.md to re-trigger the corresponding sync warning (and bootstrap an actual shim if Claude-specific semantics emerge).
- Revert the `is_tier2_file()` edit to restore the over-broad `scripts/*` rule.
- Remove the `check-commit-message` hook block to disable commit-msg enforcement.
- Move the archived proposal back to `openspec/proposals/` to undo archival.

No rollback is irreversible.

## Verification

- `sync-agent-skills --check`: 0 errors, **0 warnings** (down from 16).
- `validate-architecture.sh`, `validate-doc-indexes.sh`, `validate-skills.sh`: all PASS.
- `check-infra-secrets.sh`, `check-network-as-identity.sh .`: PASS.
- `openspec-triage.sh origin/main`: correctly classifies this PR as Tier 2 with proposal present.
- Sanity-tested triage exclusion: synthetic diff touching only `scripts/README.md` returns Tier 1; synthetic diff touching `scripts/foo.sh` returns Tier 2.
- Sanity-tested commit-msg hook: rejects `Add new thing`, accepts `feat: …`, `feat(scope)!: …`, `Merge pull request #42`, `Revert "old commit"`.
- `pre-commit run --all-files`: all hooks PASS.
