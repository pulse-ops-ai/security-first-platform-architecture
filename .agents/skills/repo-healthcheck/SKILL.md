---
name: repo-healthcheck
description: Verify a repository satisfies the security-first platform repo contract — Universal Floor present, security-first-adoption.md frontmatter populated, vendor-specific adapter files consistent with the adopter's declarations. Use when onboarding a new consuming repo, when CI needs a structural check, or when a PR is suspected of degrading structural compliance.
---

# Repo healthcheck

<!-- no-shim: claude — vendor-neutral procedure; .claude/commands/repo-healthcheck.md invokes canonical directly. -->
<!-- no-shim: codex -->

Confirm that a repository's structural shape matches the [repo contract](../../../standards/repo-contract.md). The check enforces:

- The **Universal Floor** (every consuming repo: `README.md`, `AGENTS.md`, `LICENSE`, `docs/`, `docs/INDEX.md`, `security-first-adoption.md`).
- Required **`security-first-adoption.md` frontmatter fields** populated — top-level scalars, the eight `adopted_control_layers` children, and the four named `agent_adapters_in_use` children.
- **Conditional Floor** items present when their parent directory is present (`openspec/README.md` if `openspec/` exists; `.agents/skills/INDEX.md` if `.agents/skills/` exists).
- **Vendor-Specific Adapter consistency** — declared adapters have their files; declared-false adapters do NOT have their files; any present adapter file routes to `AGENTS.md`.

This is a structural check, not a content review. Architectural compliance is a separate concern (use `architecture-review`).

## Inputs

- Path to a repository (default: current working directory).

## Procedure

1. **Run the script**:

   ```bash
   bash scripts/repo-healthcheck.sh [path]
   ```

   The script auto-detects mode:
   - **architecture-repo mode** — when `standards/repo-contract.md` is present (sentinel). The check skips `security-first-adoption.md` checks (the architecture repo IS the contract; it doesn't adopt itself) and skips adapter-declaration consistency (no declaration source). It still validates the Universal Floor and that any present adapter routes to `AGENTS.md`.
   - **consumer-repo mode** — when the sentinel is absent. Full check.

2. **Parse the output.** Findings are prefixed:
   - `[OK]` — check passed.
   - `[INFO]` — informational (e.g., mode detection).
   - `[WARN]` — soft signal; does not fail the check (e.g., `AGENTS.md` does not mention `architecture`).
   - `[ERROR]` — hard failure; the script exits non-zero.

3. **Interpret findings.** Common categories:
   - `MISSING` root file / directory → fix per the [repo contract](../../../standards/repo-contract.md).
   - Frontmatter `'<key>' is empty (or comment-only)` → open `security-first-adoption.md` and populate the field. The template uses `key: # comment` for placeholders; replace with a real value.
   - `Adapter mismatch:` → either change the `agent_adapters_in_use.<adapter>` declaration to match reality, or remove the adapter files that contradict the declaration. **Do not** add adapter files just to satisfy the check if your team doesn't use that tool.
   - `does not reference AGENTS.md` → adapter files are routers; they must reference the canonical contract, not duplicate it.

4. **Exit code** is the authoritative verdict: `0` = PASS, `1` = FAIL.

## Output

The script produces a structured report:

```
== Universal Floor ==
[OK]      README.md present
[OK]      AGENTS.md present
...

== security-first-adoption.md frontmatter ==
[OK]      frontmatter field 'adopting_repo' = trupryce
[ERROR]   frontmatter field 'architecture_ref' is empty (or comment-only)
...

== Vendor-Specific Adapters ==
[OK]      CLAUDE.md present (claude_code: true)
[ERROR]   Adapter mismatch: codex is 'false' but .codex/ is present in the tree
...

== Summary ==
mode:     consumer-repo
errors:   2
warnings: 0
repo-healthcheck: FAIL
```

When invoked via the `/repo-healthcheck` Claude command, return the report verbatim plus a one-line verdict.

## Guardrails

- Do not review application logic — use `architecture-review` for that.
- Do not validate OpenSpec proposal content — use `openspec-change-triage`.
- Treat the check as **structural only**; passing this skill does not imply architectural compliance, only that the skeleton matches the contract.
- Do not modify a consuming repo's files as part of running the skill. Report findings; the consumer's owner decides the fix.
- Do not add files (e.g., a stub `CLAUDE.md`) just to make a finding go away. If a finding is genuinely a false positive given the contract, that's a bug in the script — open an OpenSpec proposal, don't paper over it.

## See also

- [`../../../scripts/repo-healthcheck.sh`](../../../scripts/repo-healthcheck.sh) — the implementation
- [`../../../standards/repo-contract.md`](../../../standards/repo-contract.md) — the contract being enforced
- [`../../../templates/consuming-repo/security-first-adoption.md`](../../../templates/consuming-repo/security-first-adoption.md) — the adoption-record template that drives the frontmatter checks
- [`../../../scripts/validate-architecture.sh`](../../../scripts/validate-architecture.sh) — the architecture repo's *own* vendor-neutrality scanner (different concern)
