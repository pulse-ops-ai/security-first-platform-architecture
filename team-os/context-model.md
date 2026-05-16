# Context Model

> Coding agents inherit correctness from structure. The shape of the repository is the shape of the prompt.

## Why structure matters more for agents than for humans

Humans tolerate sprawl. They open the file they remember, ask a teammate, or read a wiki. Agents have none of that. An agent's "memory" is the slice of files it loads into context. If the slice is wrong, the output is wrong — confidently.

That makes folder structure, naming, and indexes load-bearing:

- A clear `INDEX.md` lets an agent navigate without reading every file.
- A predictable repo contract lets an agent know where to put new work without guessing.
- Vendor-neutral architecture docs let an agent reason about the *role*, not the *brand*.

## The four pillars of context

### 1. Indexes are the spine

Every folder with more than one file has an `INDEX.md` (or `README.md` for top-level adapter folders). Agents read the index first; they read content only when the index points there.

### 2. Standards over conventions

A convention is what people happen to do. A standard is what people are required to do. Agents respect standards (because they are written down) and miss conventions (because they are not). See [`../standards/`](../standards/).

### 3. Templates over instructions

A `templates/` folder is faster than a paragraph telling an agent how to construct a file. Agents copy templates correctly; they reconstruct instructions imperfectly. See [`../templates/`](../templates/).

### 4. Adapters route, the contract decides

`AGENTS.md` is the universal contract. Vendor-specific adapter files — current examples include `CLAUDE.md` + `.claude/` for Claude Code, `.codex/` for Codex, `.github/copilot-instructions.md` for GitHub Copilot, `.cursorrules` for Cursor — are **adapters** that route a specific tool to the contract. Adapters never overrule. If a rule belongs to all agents, it goes in `AGENTS.md` and the adapter cross-references it.

A consuming repo only needs the adapter files for the tools it actually uses. A repo that uses only one agent does not need to ship the others' adapters.

## How an agent uses this context

Recommended traversal:

1. `AGENTS.md`
2. The `INDEX.md` for the area being touched
3. The single doc the index points to
4. The relevant `standards/*.md`
5. The relevant `templates/*` if creating new artifacts
6. The relevant `.agents/skills/*/SKILL.md` if a skill applies

An agent that reads in this order needs only a small fraction of the repo to do correct work. That is the design.

## What breaks the model

- **Duplicate content.** Two files saying the same thing means the agent picks one and drifts.
- **Vendor names in core docs.** Confuses agents about whether a rule is the architecture or a profile.
- **Stale indexes.** A file referenced in an index that no longer exists. A file present in the folder but missing from the index.
- **Adapters that diverge from `AGENTS.md`.** Drift between vendor adapters and the universal contract.

The healthcheck skills exist to detect exactly these issues. See [`../.agents/skills/repo-healthcheck/SKILL.md`](../.agents/skills/repo-healthcheck/SKILL.md) and [`../.agents/skills/doc-spine-sync/SKILL.md`](../.agents/skills/doc-spine-sync/SKILL.md).
