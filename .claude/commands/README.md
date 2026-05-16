# .claude/commands/

Claude Code slash commands specific to this repo.

## Conventions

- One markdown file per command (`/my-command` → `my-command.md`).
- Each command is short and points to the canonical skill in [`../../.agents/skills/`](../../.agents/skills/) or to the document it operates on.
- Commands do not re-implement skills; they invoke them. The canonical SKILL.md is the contract.

## Commands

### Knowledge base (Notion)

- `/pull-from-notion` — see [`pull-from-notion.md`](pull-from-notion.md); invokes [`../../.agents/skills/pull-from-notion/SKILL.md`](../../.agents/skills/pull-from-notion/SKILL.md)
- `/push-to-notion` — see [`push-to-notion.md`](push-to-notion.md); invokes [`../../.agents/skills/push-to-notion/SKILL.md`](../../.agents/skills/push-to-notion/SKILL.md)

### Architecture & security review

- `/architecture-review` — invokes [`../../.agents/skills/architecture-review/SKILL.md`](../../.agents/skills/architecture-review/SKILL.md)
- `/security-control-review` — invokes [`../../.agents/skills/security-control-review/SKILL.md`](../../.agents/skills/security-control-review/SKILL.md)
- `/cross-repo-impact-review` — invokes [`../../.agents/skills/cross-repo-impact-review/SKILL.md`](../../.agents/skills/cross-repo-impact-review/SKILL.md)
- `/github-enterprise-ci-review` — invokes [`../../.agents/skills/github-enterprise-ci-review/SKILL.md`](../../.agents/skills/github-enterprise-ci-review/SKILL.md)
- `/openspec-change-triage` — invokes [`../../.agents/skills/openspec-change-triage/SKILL.md`](../../.agents/skills/openspec-change-triage/SKILL.md)

### Repo authoring

- `/architecture-decision-record` — invokes [`../../.agents/skills/architecture-decision-record/SKILL.md`](../../.agents/skills/architecture-decision-record/SKILL.md)
- `/repo-healthcheck` — invokes [`../../.agents/skills/repo-healthcheck/SKILL.md`](../../.agents/skills/repo-healthcheck/SKILL.md)
- `/doc-spine-sync` — invokes [`../../.agents/skills/doc-spine-sync/SKILL.md`](../../.agents/skills/doc-spine-sync/SKILL.md)

## Pattern

A slash command is a Claude-Code-specific entrypoint. The canonical SKILL.md is invoked via the command's prose body; the `$ARGUMENTS` placeholder receives whatever the user typed after the command.

Canonical SKILL.md files for these commands carry `<!-- no-shim: claude -->` markers because the slash command IS the Claude-specific adapter for vendor-neutral skills. A separate `.claude/skills/<name>/SKILL.md` shim would just duplicate the canonical without adding Claude-specific input semantics.
