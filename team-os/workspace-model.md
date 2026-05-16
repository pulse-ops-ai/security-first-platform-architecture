# Workspace Model

The TeamOS assumes a **sibling-repo clone model**. All repositories in the platform workspace are cloned side-by-side under a single parent directory.

## Expected local layout

```
~/work/security-first-platform/
  security-first-platform-architecture/   # this repo — source of truth
  trupryce/                                # solution repo
  findevil/                                # solution repo
  levelup-platform/                        # solution repo
  splunk-agentic-ops/                      # solution repo
  # future solution repos sit here too
```

Coding agents (Claude Code, Codex) are typically launched in **one** of these directories at a time, but the sibling layout means cross-repo lookups are cheap when needed.

## Why sibling, not monorepo

- Each solution repo has its own release cadence, owners, CI policies, and possibly its own customers.
- Mono-repo tooling adds friction without proportional benefit at this scale.
- A separate architecture repo keeps the standards visibly distinct from any one product.

## Why sibling, not unrelated

- Architecture changes affect consuming repos. A flat workspace makes those linkages tractable.
- Cross-repo dependency records (see [`cross-repo-governance.md`](cross-repo-governance.md)) reference paths under this layout.
- Agent skills (e.g., cross-repo impact review) can traverse sibling repos when invoked from the architecture repo.

## The architecture repo's role

- **Source of truth** for `AGENTS.md`, `CLAUDE.md`, standards, templates, and architecture documents.
- **Adoption kit** for new and existing solution repos.
- **Coordination point** for cross-repo work via the `portfolio/` folder.

Consuming repos **do not** copy this repo. They reference it (by name, by template snapshot, or by Git SHA) and align to it.

## What consuming repos must have

Per [`../standards/repo-contract.md`](../standards/repo-contract.md), every consuming repo has:

- `AGENTS.md` (its own, derived from the template)
- `CLAUDE.md` (its own, derived from the template)
- `docs/INDEX.md`
- `.agents/skills/INDEX.md`
- `openspec/` directory (even if empty initially)
- `.github/workflows/` with at least the doc/skill/architecture healthchecks

See [`../templates/consuming-repo/`](../templates/consuming-repo/).

## Bootstrapping a new solution repo

1. Clone it as a sibling under `~/work/security-first-platform/`.
2. Copy `templates/consuming-repo/*` into the new repo.
3. Fill in repo-specific names, owners, and links.
4. Add a dependency record back to the architecture repo: see [`../templates/dependency-record/dependency-template.md`](../templates/dependency-record/dependency-template.md).
5. Run the healthcheck skills.

## What this is not

- Not a Bazel/Pants/Nx workspace. There is no shared build system.
- Not a Git submodule layout. Each repo is independent.
- Not a strict requirement for CI — CI can clone repos individually as needed. The sibling model is for local developer & agent ergonomics.
