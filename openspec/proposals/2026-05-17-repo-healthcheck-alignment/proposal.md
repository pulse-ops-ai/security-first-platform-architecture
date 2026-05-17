---
tier: 2
status: in_review
completion_state: architecture-complete
opened: 2026-05-17
target_decision_date: 2026-05-24
authors:
  - "@mike"
---

# OpenSpec Proposal: Align `repo-healthcheck` with the repo contract

## Problem

`.agents/skills/repo-healthcheck/SKILL.md` predates PR-2's repo-contract restructure (Universal Floor vs Vendor-Specific Adapters) and predates PR-2's introduction of `security-first-adoption.md`. As a result:

- The skill requires `CLAUDE.md` and `.agents/skills/` **unconditionally**, contradicting the contract that makes them conditional on `agent_adapters_in_use.claude_code` and on whether the repo exposes local skills.
- The skill does not list `security-first-adoption.md` in its required-files set, even though the contract puts it in the Universal Floor.
- The skill does not validate that `security-first-adoption.md` frontmatter fields are populated, leaving a consuming repo's adoption record vulnerable to template-shaped (unfilled) submissions.
- The skill does not check that `agent_adapters_in_use:` declarations are consistent with adapter files present in the tree.

The drift was acknowledged in PR-12's `docs/operations/first-consumer-onboarding.md` as a "Known limitations" section with manual workarounds. That section explicitly told first adopters to **leave** `[MISSING] CLAUDE.md` and `[MISSING] .agents/skills/` findings in their report as "known false positives" — a poor first experience that depends on the adopter trusting an unwritten promise that the false positives will go away later.

The first real consumer onboarding (`trupryce`) is the next PR after this one. The skill must be aligned with the contract before that PR opens, otherwise the consumer's healthcheck report will be misleading from day one and the runbook's manual workarounds will harden into convention.

## Proposed change

Replace the prose-procedure SKILL.md with an executable check backed by `scripts/repo-healthcheck.sh`, and align all surfaces (skill, slash command, onboarding runbook) to the same procedure.

1. **NEW `scripts/repo-healthcheck.sh`** — bash, auto-detects mode via the `standards/repo-contract.md` sentinel:
   - **Architecture-repo mode**: validates the Universal Floor and that any present adapters route to `AGENTS.md`. Skips `security-first-adoption.md` checks (the architecture repo IS the contract; it does not adopt itself) and skips adapter-declaration consistency (no declaration source).
   - **Consumer-repo mode**: validates the Universal Floor + `security-first-adoption.md` frontmatter (8 required scalars + 8 `adopted_control_layers` children + 4 `agent_adapters_in_use` children + 3 required list keys) + the conditional floor + adapter consistency (each declared `true` has its files, each `false` does NOT, present adapters route to `AGENTS.md`).
2. **REWRITE `.agents/skills/repo-healthcheck/SKILL.md`** — describes the new procedure, invokes the script, documents finding categories and how to interpret each.
3. **REWRITE `.claude/commands/repo-healthcheck.md`** — invokes the script, matches the SKILL.md.
4. **UPDATE `docs/operations/first-consumer-onboarding.md`** — step 10 now invokes `bash scripts/repo-healthcheck.sh`. Removes the "Known limitations" / "Known false positives" section and the manual-grep workarounds; replaces with a concise common-errors table.
5. **UPDATE `scripts/README.md`** — document the new script.
6. **UPDATE `.pre-commit-config.yaml`** — add a `repo-healthcheck` hook scoped to files that affect contract compliance, so the architecture repo catches self-regression locally.

## Alternatives considered

- **SKILL.md-only update (no script).** The skill could just describe the new procedure as prose and let an agent execute it manually each time. Rejected because requirements #5 and #6 (validate frontmatter field population; validate adapter declaration ↔ file consistency) need real parsing logic — leaving them to the agent each time produces inconsistent enforcement and means CI cannot run the check. The script makes the rule executable.
- **Python implementation with a YAML library.** Cleaner parsing of `security-first-adoption.md` than bash. Rejected because (a) the existing scripts are bash and the team has standardized there; (b) the YAML shape used by the template is simple enough that targeted bash extractors handle the cases that matter; (c) adding Python would introduce a runtime dependency on consuming repos that don't already have it. Documented as a "future refactor candidate" if the frontmatter shape grows.
- **Defer the alignment, ship trupryce onboarding with the manual workarounds.** Rejected because the workarounds harden into convention; once the first consumer's pattern is "ignore these known false positives," changing the skill later requires re-educating every adopter.
- **Mode flag (`--mode consumer | architecture`) instead of sentinel auto-detection.** Considered for explicitness. Rejected as ergonomically worse — the sentinel is unambiguous (`standards/repo-contract.md` only lives in the architecture repo) and removes one invocation parameter the operator has to remember.
- **Strict YAML schema validation (e.g., yaml-schema).** Considered. Rejected as scope creep for this PR; the targeted bash extractors catch the failure modes the contract actually cares about. A schema-based validator can replace the bash extractors in a future refactor without changing what the skill enforces.

## Impact

- **Repos affected:** the architecture repo only. The trupryce onboarding PR (next, in a sibling repo) will use the aligned skill on first run.
- **Layers / profiles affected:** none.
- **Standards affected:** none in content; the skill now correctly enforces what `standards/repo-contract.md` already says.
- **Templates affected:** none.
- **Cross-repo contracts:** none.
- **Security-boundary impact:** none directly. The skill strengthens *adoption-time discipline* (consumers can't silently ship an unfilled adoption record) but does not change any control-layer behavior.

## Affected consumers (Tier 2/3 only)

| Consumer repo | Affected artifact | Dependency record | Owner |
|---|---|---|---|
| _(none yet — trupryce is the planned first adopter, onboarding in the next PR)_ | n/a | n/a | n/a |

`completion_state: architecture-complete`. No consumer has onboarded yet. Once trupryce onboards (in a separate PR in the trupryce repo), they will be the first user of the aligned skill.

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`
- **`deprecation_window:`** `n/a` — the prose-procedure version of the skill is being **replaced**, not deprecated alongside the new one. Anyone (human or agent) who follows the SKILL.md after this PR merges gets the new procedure. The slash command and onboarding runbook all point at the new procedure simultaneously.
- **Migration steps:**
  1. Merge this PR.
  2. The next consumer onboarding (trupryce) uses the aligned skill on first run — surfaces any remaining gaps in real use.
  3. Any future script refactor (e.g., YAML-schema validator) supersedes the current bash implementation without changing the skill's contract.

## Completion criteria

`completion_state: architecture-complete`

- `scripts/repo-healthcheck.sh` exists, executable, smoke-tested in both modes (architecture-repo and consumer-repo).
- `SKILL.md`, slash command, onboarding runbook, scripts README, and pre-commit config all reference the new script.
- All pre-existing validators continue to pass.
- The new script PASSes when run against the architecture repo itself (proves the architecture repo follows its own contract).
- No consumer migration required (no consumers yet).

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete file diffs
- [`tasks.md`](tasks.md) — execution plan
- No ADRs (Tier 2; no foundational architectural trade-off being captured)
- No dependency records (no consumer impact yet)
- PR #12 — surfaced the contract gap that this PR closes
