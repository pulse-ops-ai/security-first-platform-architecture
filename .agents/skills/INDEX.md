# .agents/skills/ — Catalog

Executable, vendor-neutral agent skills for this repo. This directory is the **canonical home** for skills; Claude / Codex / future adapters under `.claude/skills/` and `.codex/skills/` are shims that reference these.

Every skill is a single folder with one `SKILL.md` that begins with YAML frontmatter (`name`, `description`). See [`../../standards/agent-instructions-standard.md`](../../standards/agent-instructions-standard.md) for the structure.

## Repo & doc hygiene

| Skill | Purpose |
|---|---|
| [`repo-healthcheck`](repo-healthcheck/SKILL.md) | Verify a repo satisfies the repo contract |
| [`doc-spine-sync`](doc-spine-sync/SKILL.md) | Detect drift between `INDEX.md` files and their folders |

## Architecture & security

| Skill | Purpose |
|---|---|
| [`architecture-review`](architecture-review/SKILL.md) | Review a change for architecture compliance |
| [`security-control-review`](security-control-review/SKILL.md) | Review a change for trust-zone integrity |
| [`architecture-decision-record`](architecture-decision-record/SKILL.md) | Draft a new ADR using the template |

## Governance & cross-repo

| Skill | Purpose |
|---|---|
| [`openspec-change-triage`](openspec-change-triage/SKILL.md) | Triage whether a change needs OpenSpec |
| [`cross-repo-impact-review`](cross-repo-impact-review/SKILL.md) | Identify which consuming repos a change affects |
| [`github-enterprise-ci-review`](github-enterprise-ci-review/SKILL.md) | Check that CI matches the CI/CD standard |

## Knowledge base (Notion)

| Skill | Purpose |
|---|---|
| [`pull-from-notion`](pull-from-notion/SKILL.md) | Pull targeted context from the Security-First Platform Notion knowledge base |
| [`push-to-notion`](push-to-notion/SKILL.md) | Persist decisions, summaries, or briefs back into Notion |

## Diagramming

| Skill | Purpose |
|---|---|
| [`drawio`](drawio/SKILL.md) | Author and export `.drawio` diagrams (architecture, trust-zone, deployment topology); applies the visual vocabulary in [`../../standards/diagramming-conventions.md`](../../standards/diagramming-conventions.md) |
| [`mermaid-diagram`](mermaid-diagram/SKILL.md) | Author Mermaid sequence / flowchart / state / ER / class diagrams that render inline in GitHub markdown; companion to `drawio` for diagrams that should not live in a separate file |

## Conventions

- Skill folder names are kebab-case.
- Every skill folder has exactly one `SKILL.md`.
- Each `SKILL.md` opens with YAML frontmatter (`name`, `description`) so agent runtimes can match the skill by description.
- Skills are vendor-neutral. Vendor-specific shims (`.claude/skills/`, `.codex/skills/`) reference the canonical skill rather than duplicating it.
- Slash-command surfacing for Claude lives in [`../../.claude/commands/`](../../.claude/commands/).
