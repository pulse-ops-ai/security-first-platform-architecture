# Repo Contract

Every repository in the workspace — architecture, solution, or tooling — must contain the following structure.

## Required files at the root

| Path | Purpose |
|---|---|
| `README.md` | Human-facing landing page |
| `AGENTS.md` | Universal agent contract for this repo |
| `CLAUDE.md` | Claude Code adapter (routes to `AGENTS.md`) |
| `LICENSE` | Required for org-published repos |

## Required directories

| Path | Purpose |
|---|---|
| `docs/` | All documentation other than top-level files |
| `docs/INDEX.md` | Index of `docs/` content |
| `.agents/skills/` | Canonical, vendor-neutral agent skills |
| `.agents/skills/INDEX.md` | Catalog of skills in this repo |
| `openspec/` | OpenSpec proposals and changes (may be empty initially) |
| `.github/workflows/` | At least the three healthcheck workflows from [`ci-cd-standard.md`](ci-cd-standard.md) |

## Required adapters (optional but recommended)

| Path | Purpose |
|---|---|
| `.claude/` | Claude Code adapter (CLAUDE.md, `.claude/skills/` shims, `.claude/commands/`, `.claude/agents/`) |
| `.codex/` | Codex adapter |

If a repo uses Claude Code or Codex, the adapter directory **must** be present and **must** route to `AGENTS.md` rather than duplicating it. Adapter skills under `.claude/skills/` or `.codex/skills/` are shims; the canonical skill lives in `.agents/skills/`.

## File contents

- `AGENTS.md` and `CLAUDE.md` must follow the templates in [`../templates/consuming-repo/`](../templates/consuming-repo/).
- `docs/INDEX.md` must list every `*.md` file under `docs/` (recursively or by category).
- `.agents/skills/INDEX.md` must list every skill under `.agents/skills/`.
- Each `.agents/skills/<name>/` directory must contain a `SKILL.md` with YAML frontmatter and the required body sections (see [`agent-instructions-standard.md`](agent-instructions-standard.md)).

## What this contract does NOT mandate

- Programming language, build tool, framework.
- Test runner.
- Deploy pipeline beyond the three healthchecks.
- Folder layout *inside* `docs/`, `.agents/skills/`, or `src/`.

The contract is about **structural alignment**, not implementation. Inside `docs/`, structure your content however your product needs.

## Adoption

A new repo can be made compliant by:

1. Copying [`../templates/consuming-repo/`](../templates/consuming-repo/) into the new repo.
2. Filling in repo-specific names, owners, and links.
3. Running the `repo-healthcheck` skill ([`../.agents/skills/repo-healthcheck/SKILL.md`](../.agents/skills/repo-healthcheck/SKILL.md)).

## Verification

The `repo-healthcheck` skill enforces this contract. CI workflows in this repo and in consuming repos call into the same checks.
