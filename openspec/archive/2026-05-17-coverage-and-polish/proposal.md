---
tier: 2
status: accepted
completion_state: architecture-complete
opened: 2026-05-17
target_decision_date: 2026-05-24
accepted_date: 2026-05-16
archived_date: 2026-05-16
merged_pr: 8
authors:
  - "@mike"
---

# OpenSpec Proposal: Coverage Closure and Polish

## Problem

After PR-3, the enforcement layer is live but several follow-ups remained explicitly deferred:

- `sync-agent-skills --check` reports **16 advisory warnings** — each of the 8 scaffold skills is missing both a Claude shim and a Claude slash command. These warnings are noise that obscure real signal.
- `openspec-triage.sh` over-classifies `scripts/*.md` as Tier 2 (`scripts/README.md` should be Tier 1 — it's documentation).
- `.pre-commit-config.yaml` declares `default_install_hook_types: [pre-commit, commit-msg]` but no `commit-msg` hook exists. Dead config.
- Branch protection is described in `team-os/github-enterprise-ci.md` but no operational runbook documents the exact `gh api` invocation to apply or audit it.
- The first OpenSpec proposal (`2026-05-16-enforcement-and-skill-rigor`) has reached its completion criteria (PR-3 merged with new gates green) but is still sitting under `openspec/proposals/` instead of `openspec/archive/`.

None of these are blockers individually; together they are the rough edges that erode trust in the system. PR-4 closes them.

This is a Tier 2 change: modifies skill bodies (adds opt-out markers), adds files under `.claude/commands/`, modifies a CI script (`openspec-triage.sh`), adds a `commit-msg` hook, and adds an operational doc. It does not modify any contract or eight-layer surface.

## Proposed change

Eight tightly-scoped follow-ups (six original + two added during PR-8 review):

1. **Close the 16 sync warnings.** Add 8 Claude slash commands (one per scaffold skill) under `.claude/commands/`. Add `<!-- no-shim: claude -->` and `<!-- no-shim: codex -->` opt-out markers in each canonical SKILL.md body — these skills are vendor-neutral and don't need adapter shims.
2. **Tighten triage script.** Update `is_tier2_file()` in `scripts/openspec-triage.sh` so `scripts/*.md` is Tier 1, `scripts/*.sh` / `*.py` / `*.rb` / `*.js` / `*.ts` stay Tier 2, and unknown extensions under `scripts/` err safely toward Tier 2.
3. **Add commit-msg hook.** New `scripts/check-commit-message.sh` enforces the conventional-commits prefix the team has been using by convention. Wired into `.pre-commit-config.yaml` as the `check-commit-message` hook on the `commit-msg` stage.
4. **Branch-protection ops runbook.** New `docs/operations/branch-protection.md` documents the desired branch-protection state for `main`, the `gh api` commands to apply or audit it, and explicit reasoning for why this isn't code-enforced.
5. **Archive first proposal.** Move `openspec/proposals/2026-05-16-enforcement-and-skill-rigor/` to `openspec/archive/`. Update its frontmatter from `status: in_review` to `status: accepted` with `accepted_date` and `archived_date`.
6. **Self-document.** Update `.claude/commands/README.md` to list all 10 commands by group. Update `docs/operations/INDEX.md` to link the new runbook. Update `openspec/README.md` to reflect the archive split.
7. **Dependabot exemption in the OpenSpec triage script.** When `GITHUB_ACTOR == 'dependabot[bot]'`, classify as Tier 1 and exit `PASS` without requiring a proposal. Other CI gates (pre-commit, gitleaks, codeowners-check) still apply, so the bot cannot land arbitrary changes — only action-version bumps with pinned SHAs/tags. Without this, every weekly Dependabot PR fails the `openspec-triage` workflow.
8. **Extend `validate-doc-indexes.sh` to emit `[BROKEN]` and `[ORPHAN]` findings.** The `doc-spine-sync` canonical SKILL.md spec called out three finding categories (UNLISTED, BROKEN, ORPHAN); the script previously emitted only UNLISTED. Closes the spec/implementation gap surfaced in PR-8 review.

## Alternatives considered

- **Bootstrap full `.claude/skills/` shims for each scaffold skill** instead of opting out. Rejected. The scaffold skills are vendor-neutral; a Claude-side shim would just duplicate the canonical without adding `$ARGUMENTS`-style semantics or any other Claude-specific value. The slash command IS the Claude adapter for these skills.
- **Remove `commit-msg` from `default_install_hook_types`** instead of adding a hook. Rejected. The team is already following conventional-commits in practice (every PR title and commit so far). A 60-line bash script that catches regressions is cheaper than untangling history later.
- **Adopt a third-party commitlint / commitizen hook.** Rejected. The local bash script has no Python dependency, no node dependency, and is trivially auditable. Revisit if the rule surface grows.
- **Enforce branch protection from a workflow.** Rejected. A workflow that can change branch protection can also remove it; that trust level is operator-only. Documented in the runbook.

## Impact

- **Repos affected:** the architecture repo only.
- **Layers / profiles affected:** none.
- **Standards affected:** none.
- **Templates affected:** none.
- **Cross-repo contracts:** none.
- **Security-boundary impact:** none directly. The branch-protection runbook strengthens the development boundary by documenting it, but doesn't change any control-layer behavior.

## Affected consumers (Tier 2/3 only)

| Consumer repo | Affected artifact | Dependency record | Owner |
|---|---|---|---|
| _(none — pure architecture-repo polish)_ | n/a | n/a | n/a |

`completion_state: architecture-complete` — no consumer action required. The new slash commands will be available to Claude Code users in any repo that has Claude Code installed, but their use is opt-in.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`
- **`deprecation_window:`** `n/a` (no pattern superseded)
- **Migration steps:**
  1. Merge this PR.
  2. Confirm the four CI workflows pass on `main`.
  3. The next PR that uses `/architecture-review` or any other new slash command exercises the commands end-to-end.

## Completion criteria

`completion_state: architecture-complete`

- All 6 follow-up items shipped.
- `sync-agent-skills --check` reports 0 warnings (down from 16).
- `openspec-triage.sh` correctly classifies `scripts/README.md`-only diffs as Tier 1.
- `commit-msg` hook accepts the commits in this PR and rejects a synthetic non-conforming message.
- First proposal sits under `openspec/archive/` with updated status.
- All four pre-existing validators continue to pass.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete file diffs
- [`tasks.md`](tasks.md) — execution plan
- No ADRs (Tier 2)
- No dependency records (no consumer impact)
