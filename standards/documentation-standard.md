# Documentation Standard

How documentation is structured in every repo. The structural rules about *which files must exist* live in [`repo-contract.md`](repo-contract.md). This document covers *how* the documentation inside those files is organized.

## Top-level docs

The repo contract defines a **Universal Floor** of docs every repo has:

- `README.md` — what the repo is, how to navigate it, who to ask.
- `AGENTS.md` — universal agent contract (separate from `README.md`; agents read it first).
- `LICENSE` — required.
- `security-first-adoption.md` — adoption record per the [repo contract](repo-contract.md).

Vendor-specific adapter files (`CLAUDE.md`, `.github/copilot-instructions.md`, etc.) exist only when that tool is in use. See [`repo-contract.md`](repo-contract.md) for the full rule.

## The `docs/` tree

```
docs/
  INDEX.md
  product/
    INDEX.md
    ...
  operations/
    INDEX.md
    ...
  decisions/
    INDEX.md
    ADR-*.md
```

Adjust the subcategories to fit the repo, but keep:

- A top-level `docs/INDEX.md`.
- One `INDEX.md` per subdirectory.
- Decisions captured as **ADRs** (Architecture Decision Records) using [`../templates/adr/ADR-template.md`](../templates/adr/ADR-template.md).

## Indexes

Every `INDEX.md` is a navigation file, not a content file. Rules:

- Lists files in the folder with a one-line description.
- Groups files into logical sections.
- May link to peer indexes (`../sibling/INDEX.md`).
- Does **not** duplicate the content of files it references.

When you add, rename, or remove a file, update the index in the same PR. The `doc-spine-sync` skill ([`../.agents/skills/doc-spine-sync/SKILL.md`](../.agents/skills/doc-spine-sync/SKILL.md)) flags drift.

## Writing style

- **Specific over generic.** "The orchestrator signs envelopes" beats "a component handles security."
- **Vendor neutrality.** In architecture docs, prefer roles over vendors. Vendors belong in profiles.
- **Cross-references, not duplication.** Link to the canonical place; do not repeat content.
- **One concept per file.** Long files are agent-hostile.
- **Examples are concrete and small.** Pseudocode is fine; full apps are not.

## Naming

- Files are kebab-case: `agent-as-client-model.md`, not `AgentAsClientModel.md`.
- Indexes are always `INDEX.md` (uppercase) for predictability.
- ADRs are `ADR-NNNN-short-title.md`.

## Diagrams

- Prefer ASCII diagrams in `.md` files. They survive every editor and merge cleanly.
- For complex diagrams, store source in `docs/diagrams/` and reference both source and rendered output.
- Do not generate diagrams that duplicate textual content; the diagram should add information.

## What does NOT belong in `docs/`

- Application code.
- Generated content that goes stale fast (auto-regenerate, or do not commit).
- Slide decks (link to a managed asset, do not commit binary copies if avoidable).
