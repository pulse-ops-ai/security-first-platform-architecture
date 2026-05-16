# Agent Instructions Standard

How agent-facing files (`AGENTS.md`, `CLAUDE.md`, `.agents/`, `.claude/`, `.codex/`, skills) are written and organized.

## Directory convention

| Directory | Purpose |
|---|---|
| `AGENTS.md`              | Universal, vendor-neutral agent contract (source of truth) |
| `.agents/skills/`        | **Canonical** vendor-neutral skills |
| `.claude/`               | Claude Code adapter (`CLAUDE.md` at root, `.claude/skills/` shims, `.claude/commands/` slash commands, `.claude/agents/` sub-agents) |
| `.codex/`                | Codex adapter (`.codex/skills/` shims, `.codex/agents/` agents) |
| Other adapters           | Same role as `.claude/` / `.codex/`. No overrides over `AGENTS.md`. |

If a vendor file ever conflicts with `AGENTS.md`, `AGENTS.md` wins.

## What belongs where

### `AGENTS.md`

- The operating principles every agent must follow in this repo.
- The map: "if you want to do X, start at Y."
- The rules: don'ts and dos.
- The escalation path for OpenSpec / ADR / dependency records.
- **Vendor-neutral.** No "use the Claude X tool" — that's adapter-level.

### `CLAUDE.md` / `.claude/`

- A short adapter that says "read `AGENTS.md` first."
- `.claude/skills/` shims that reference canonical skills in `.agents/skills/`.
- `.claude/commands/` slash commands.
- `.claude/agents/` sub-agent definitions.
- Never the place to put rules that should apply to all agents.

### `.codex/`

- Same idea for Codex.

### `.agents/skills/`

- Canonical executable skills usable by any agent runtime that supports skills.
- Each skill is a single folder with one `SKILL.md`.
- Vendor-specific adapter folders (`.claude/skills/`, `.codex/skills/`) **shim** to the canonical skill — they don't duplicate it.

## SKILL.md structure

A `SKILL.md` is concise, executable, and agent-friendly.

### Required: YAML frontmatter

```yaml
---
name: <kebab-case-skill-name>     # must match the directory name
description: <what the skill does + when to use it>  # used by agent runtimes to match the skill to a request
---
```

The `description` should make the *when-to-use* obvious — agent runtimes match a request to a skill primarily through this field. Lead with the action ("Pull relevant context from..."), then state triggers ("Use when the user asks to load project context, ..."), so the description carries both purpose and activation hints.

Optional frontmatter fields:

- `argument-hint:` — placeholder for invocation arguments (used by Claude commands).
- `model:` — preferred model if the skill has a strong reason to specify one.

### Required: body sections

After the frontmatter, in this order:

1. **`# <Title>`** — a one-line title, then one paragraph of purpose.
2. **`## Procedure`** — the numbered or bulleted procedure the agent follows. Each step is a clear action; no vibes.
3. **`## Output`** — what the agent returns when the skill finishes.
4. **`## Guardrails`** — explicit don'ts and edge cases. "When not to use" lives here.

### Optional: body sections

- `## Inputs` — what the agent needs as arguments or pre-loaded context. Use when inputs are non-obvious.
- `## Known sources` / `## References` — links to data sources, sibling skills, or related standards.
- `## See also` — cross-references to other skills, standards, or templates.

### Length

A `SKILL.md` is not an essay. If it exceeds ~150 lines, split it. Long skills make agents slower and less correct.

## Canonical ↔ shim drift rules

Skills have one canonical home (`.agents/skills/`) and zero or more vendor shims (`.claude/skills/`, `.codex/skills/`, plus Claude slash commands under `.claude/commands/`). The relationship is enforced by [`../scripts/sync-agent-skills.sh`](../scripts/sync-agent-skills.sh) and runs in CI as part of `skills-healthcheck.yml`.

### What's enforced (errors — fail CI)

- Every shim must have a matching canonical skill at `.agents/skills/<name>/SKILL.md`.
- Shim frontmatter `name:` must match the canonical's `name:` and the shim's directory name.
- Shims must have a `description:` in frontmatter.
- Shims must include `## Procedure` **or** explicitly reference / delegate to the canonical (e.g., link to `.agents/skills/<name>/SKILL.md`).
- Shims must include `## Output` **or** carry an `output-not-applicable:` marker.
- Orphan Claude slash commands (`.claude/commands/<name>.md` with no canonical) fail unless marked `command-only: true`.

### What's advisory (warnings — non-blocking)

- Missing Claude shim for a canonical skill that hasn't opted out.
- Missing Claude slash command for a canonical skill that hasn't opted out.
- Missing Codex shim **only when** `.codex/skills/` is in active use repo-wide (at least one populated shim folder).

### Opt-out markers

These markers may appear anywhere in the relevant file — as HTML comments, code-fenced lines, frontmatter fields, or plain lines. The drift script matches them as substrings.

| Marker | Where it goes | Effect |
|---|---|---|
| `no-shim: claude` | canonical `.agents/skills/<name>/SKILL.md` | this skill does not need a Claude shim |
| `no-shim: codex` | canonical `.agents/skills/<name>/SKILL.md` | this skill does not need a Codex shim |
| `no-command: claude` | canonical `.agents/skills/<name>/SKILL.md` | this skill does not need a `/<name>` Claude command |
| `command-only: true` | `.claude/commands/<name>.md` | this slash command has no canonical skill backing (rare) |
| `output-not-applicable:` | shim `SKILL.md` | this shim legitimately has no `## Output` section |

### Bootstrapping a new shim

To create a starter Claude or Codex shim from an existing canonical skill:

```
bash scripts/sync-agent-skills.sh --bootstrap <skill-name> --vendor claude
bash scripts/sync-agent-skills.sh --bootstrap <skill-name> --vendor codex
```

The bootstrap copies the canonical content, injects `argument-hint:` into Claude shims, and appends a traceability footer. Refuses to overwrite an existing shim without `--force`. Codex bootstrap requires `.codex/skills/` to already exist in the repo.

## Anti-patterns

- **Long `AGENTS.md` files.** Use the index pattern: state the rules, then point to the documents that elaborate.
- **Rules in `CLAUDE.md` that aren't in `AGENTS.md`.** Other agents won't see them.
- **Skills without frontmatter.** Agent runtimes can't match them to requests.
- **Skills that ask the agent to "use good judgment."** Skills are procedures, not vibes.
- **Skill files that duplicate architecture or standards content.** Cross-reference instead.
- **Adapter shims that re-state the canonical procedure.** Shims reference the canonical skill; they don't fork it.

## Maintenance

- `AGENTS.md` updates require an OpenSpec proposal at Tier 2 / Tier 3 (see [`../team-os/openspec-policy.md`](../team-os/openspec-policy.md)).
- Adapter updates that *route differently* are Tier 1; adapters that *change behavior* are Tier 2.
- Skill additions are Tier 1 if additive; skill changes that alter outputs are Tier 2.
