# .claude/commands/

Claude Code slash commands specific to this consuming repo.

## Conventions

- One markdown file per command (`/my-command` → `my-command.md`).
- Each command is short and either:
  - Operates on this repo's content (e.g., a `/release-notes` command that reads `CHANGELOG.md`), OR
  - Routes to a canonical skill in the **sibling architecture repo**. The architecture repo lives next to this one under the workspace parent directory; **from your repo root**, that's at `../security-first-platform-architecture/` and the canonical skills are at `.agents/skills/<name>/SKILL.md` inside that sibling.
- Commands do not re-implement skills; they invoke them.

## Recommended consumer commands

The architecture repo ships these skills that are useful from a consumer context (paths shown below are from **your consumer repo's root**, not from `.claude/commands/`):

- `/repo-healthcheck` — runs `repo-healthcheck.sh` against this repo (consumer-repo mode). The architecture repo's `.claude/commands/repo-healthcheck.md` is a working starting point; copy it here and adjust the invocation to reach the sibling, e.g., `bash ../security-first-platform-architecture/scripts/repo-healthcheck.sh .`.
- `/architecture-review` — reviews PRs for architectural drift against the pinned architecture-repo ref.
- `/security-control-review` — runs the network-as-identity scanner and the control-layer checks.
- `/cross-repo-impact-review` — discovers sibling repos and finds references to architecture-repo artifacts.
- `/openspec-change-triage` — classifies a PR's tier and confirms a proposal exists when required.

You don't need to ship all of these — pick the ones your team actually uses.

## Currently defined

_None yet._ Add commands as recurring workflows emerge.
