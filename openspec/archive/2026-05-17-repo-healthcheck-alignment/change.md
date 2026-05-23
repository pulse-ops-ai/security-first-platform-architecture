# OpenSpec Change: Align `repo-healthcheck` with the repo contract

Companion to [`proposal.md`](proposal.md).

## Files added

- **`scripts/repo-healthcheck.sh`** — bash, auto-detects mode via the `standards/repo-contract.md` sentinel.
  - Consumer mode checks:
    - Universal Floor: `README.md`, `AGENTS.md`, `LICENSE`, `docs/`, `docs/INDEX.md`, `security-first-adoption.md`.
    - `security-first-adoption.md` frontmatter: 8 required scalars (`adopting_repo`, `architecture_repo`, `architecture_ref`, `architecture_ref_kind`, `adoption_date`, `review_cadence`, `owner`, `profile`); 8 children of `adopted_control_layers` (l1–l8, must be `implemented` | `consumed` | `n/a`); 4 children of `agent_adapters_in_use` (`claude_code`, `codex`, `github_copilot`, `cursor`, must be `true` | `false`); 3 required list keys (`deviations`, `pending_openspec_changes`, `cross_repo_dependencies` — presence only, `[]` acceptable).
    - Conditional Floor: `openspec/README.md` if `openspec/` exists; `.agents/skills/INDEX.md` if `.agents/skills/` exists; `.github/workflows/` if `.github/` exists.
    - Adapter consistency: each `agent_adapters_in_use.<x>: true` has its corresponding file(s); each `: false` does NOT; any present adapter file references `AGENTS.md`.
    - `AGENTS.md` non-empty + references "architecture" and "team-os" (warning if either missing).
  - Architecture-repo mode: skips `security-first-adoption.md` checks and adapter-declaration consistency; still validates Universal Floor + adapter routing.
  - Exit codes: 0 PASS, 1 FAIL (any errors), 2 invocation error.
- **`openspec/proposals/2026-05-17-repo-healthcheck-alignment/{proposal,change,tasks}.md`** — this proposal.

## Files modified

- **`.agents/skills/repo-healthcheck/SKILL.md`** — replaces the prose procedure (which incorrectly required `CLAUDE.md` and `.agents/skills/` unconditionally) with an invoke-the-script procedure. Documents finding categories (`OK`/`INFO`/`WARN`/`ERROR`) and how to interpret each common error. Keeps the `<!-- no-shim: claude/codex -->` markers and the `## Guardrails` / `## See also` sections.
- **`.claude/commands/repo-healthcheck.md`** — replaces step-by-step manual checks with `bash scripts/repo-healthcheck.sh` + interpretation guidance. Adds a guardrail explicitly forbidding adapter-file-as-cure-for-finding ("don't add CLAUDE.md just to satisfy a [MISSING] finding").
- **`docs/operations/first-consumer-onboarding.md`** — step 10 rewritten:
  - Replaces multi-block "what the skill checks today / does NOT check today / manual workaround / known limitations" with a single block invoking the script + a 4-row common-errors table.
  - Removes the "known false positives" guidance entirely (no longer applies).
  - Removes the "Known limitations of the validators (as of 2026-05-17)" subsection (the limitation is closed).
  - Keeps the note that `validate-architecture.sh` is the architecture repo's *own* scanner (still useful guidance).
- **`scripts/README.md`** — adds `repo-healthcheck.sh` to the catalog table; adds it to the "Running locally" block.
- **`.pre-commit-config.yaml`** — adds `repo-healthcheck` hook scoped to floor / contract-relevant paths (README.md, AGENTS.md, CLAUDE.md, LICENSE, security-first-adoption.md, docs/**, .agents/skills/**, .claude/**, .codex/**, .github/copilot-instructions.md, .cursorrules, openspec/README.md, standards/repo-contract.md, scripts/repo-healthcheck.sh). Auto-detect handles architecture-repo vs consumer-repo mode.

## Contract changes

None. The skill is being aligned with the contract that PR-2 already established; the contract itself is unchanged.

## Cross-repo migration steps

None. `completion_state: architecture-complete`. The first consumer (`trupryce`) will use the aligned skill in its onboarding PR (next).

## Rollback

Each change is independently revertible:

- Delete `scripts/repo-healthcheck.sh` to remove the new script.
- Revert the SKILL.md, slash command, and onboarding doc changes to restore the prior prose procedure.
- Remove the `repo-healthcheck` hook entry from `.pre-commit-config.yaml`.
- Move the proposal directory to `openspec/archive/` to close it without action.

No rollback is irreversible.

## Verification

- `bash scripts/repo-healthcheck.sh` in the architecture repo: PASSes (0 errors, 0 warnings) in architecture-repo mode.
- Smoke-tested in consumer mode against a synthetic fully-populated `security-first-adoption.md`: PASSes.
- Smoke-tested in consumer mode against the template-shaped (unfilled) `security-first-adoption.md`: catches 19 errors (7 scalars + 8 layer children + 4 adapter children, exactly as expected).
- Smoke-tested adapter mismatch (`claude_code: false` with `CLAUDE.md` present): catches the mismatch.
- Smoke-tested missing `security-first-adoption.md`: catches with the correct error message.
- All pre-existing validators pass: `validate-architecture.sh`, `validate-doc-indexes.sh`, `validate-skills.sh`, `sync-agent-skills.sh --check`, `check-infra-secrets.sh`, `check-network-as-identity.sh`, `openspec-triage.sh`.
- `pre-commit run --all-files` — full hook chain PASSes (now includes `repo-healthcheck`).
