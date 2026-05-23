# Repo Contract

Every repository in the workspace — architecture, solution, or tooling — adheres to this contract.

The contract is split into two layers:

- the **Universal Floor** — files every consuming repo MUST have, regardless of which tools or vendors it uses, and
- **Vendor-Specific Adapters** — files that are required *only when that vendor or tool is in use*.

The validators (`scripts/validate-architecture.sh`, the `repo-healthcheck` skill, and the `pre-commit` hook chain) enforce this contract. The floor is non-negotiable; adapter files are only checked when the corresponding vendor folder exists.

## Universal Floor (required in every consuming repo)

| Path | Purpose |
|---|---|
| `README.md` | Human-facing landing page |
| `AGENTS.md` | **Universal, vendor-neutral agent contract** for this repo — the source of truth that all adapters route to |
| `LICENSE` | Required for org-published repos |
| `docs/` | All documentation other than top-level files |
| `docs/INDEX.md` | Index of `docs/` content |
| `security-first-adoption.md` | Adoption record — pins which architecture-repo ref this consumer tracks, declares profile, deviations, owner, and review cadence (see [`../templates/consuming-repo/security-first-adoption.md`](../templates/consuming-repo/security-first-adoption.md)) |
| `openspec/README.md` *(if the repo uses OpenSpec)* | OpenSpec entrypoint. Repos that have not yet needed OpenSpec may defer this; once any Tier 2/3 change is opened, the entrypoint becomes mandatory |
| `.github/workflows/` *(if the repo owns its own CI)* | At minimum the three healthcheck workflows from [`ci-cd-standard.md`](ci-cd-standard.md). Repos whose CI is owned by a parent or platform pipeline may omit this directory and reference the parent instead in their adoption record |

The floor is intentionally **agent-neutral**. A consuming repo that uses no AI coding agents at all still has `AGENTS.md` so future agents have a contract to follow.

## Vendor-Specific Adapters (required ONLY when that tool is used)

| Path | Required when | Purpose |
|---|---|---|
| `CLAUDE.md` + `.claude/` | the repo uses Claude Code | Claude Code adapter — routes to `AGENTS.md` and provides Claude-specific skill shims, slash commands, sub-agents |
| `.codex/` | the repo uses Codex | Codex adapter — same pattern |
| `.github/copilot-instructions.md` | the repo uses GitHub Copilot | Copilot adapter — same pattern |
| `.cursorrules` | the repo uses Cursor | Cursor adapter — same pattern |
| `.agents/skills/` + `.agents/skills/INDEX.md` | the repo exposes repo-local agent skills | Canonical, vendor-neutral skill catalog. Repos that consume only architecture-repo skills don't need this; repos with their own product-specific skills do |

**Rule:** if an adapter directory exists, the validators check that it routes to `AGENTS.md` and does not duplicate or contradict it. If the adapter directory doesn't exist, no check runs — the repo is simply declaring "we don't use that tool."

This means: a consuming repo that uses only one agent ships only that agent's adapter. A repo that wants to be tool-agnostic ships only `AGENTS.md` and lets each contributor configure their own tooling locally.

## File-content rules

- `AGENTS.md` must follow the template in [`../templates/consuming-repo/AGENTS.md`](../templates/consuming-repo/AGENTS.md).
- Each vendor adapter, if present, must follow its respective template in [`../templates/consuming-repo/`](../templates/consuming-repo/).
- `docs/INDEX.md` must list every `*.md` file under `docs/` (recursively or by category).
- `security-first-adoption.md` must populate every required field — empty fields fail the `repo-healthcheck` skill.
- If `.agents/skills/` exists: `.agents/skills/INDEX.md` must list every skill, and each `.agents/skills/<name>/` directory must contain a `SKILL.md` with the YAML frontmatter and body sections defined in [`agent-instructions-standard.md`](agent-instructions-standard.md).

## What the consumer template ships

[`../templates/consuming-repo/`](../templates/consuming-repo/) is **complete out of the box** — copying it gives a consuming repo the Universal Floor plus a working CI setup, with no requirement to author workflows or pre-commit configs from scratch:

| Path | What it is |
|---|---|
| `AGENTS.md`, `CLAUDE.md`, `docs/INDEX.md`, `security-first-adoption.md`, `openspec/README.md`, `.agents/skills/INDEX.md` | Universal Floor + skill catalog (remove `.agents/skills/INDEX.md` if not exposing local skills) |
| `.claude/{skills,commands,agents}/README.md` | Claude adapter shim directory READMEs (remove the whole `.claude/` tree if not using Claude) |
| `.github/workflows/repo-healthcheck.yml`, `docs-healthcheck.yml`, `pre-commit.yml` | Thin callers that invoke the architecture repo's reusable workflows. These three ARE the universal-floor CI baseline defined in [`ci-cd-standard.md`](ci-cd-standard.md) §Required workflows. Each has an `__ARCHITECTURE_REF__` placeholder the adopter substitutes during onboarding. |
| `.github/CODEOWNERS` | Placeholder consumer-shaped ownership map (`@<solution-team>` / `@<consumer-lead>` substitution required). |
| `.pre-commit-config.yaml` | Consumer-portable hook chain (file hygiene + secrets + shellcheck, no architecture-repo script dependencies). |
| `.secrets.baseline` | Empty starting baseline for `detect-secrets`. |
| `.gitleaks.toml` | Narrow allowlist for `.secrets.baseline` (the hashed_secret values would otherwise trip the generic-api-key rule). |

The template's CI works by **calling the architecture repo's reusable workflows** rather than vendoring scripts. The adopter's `architecture_ref:` in `security-first-adoption.md` is the source of truth for which version of those reusables runs — bumping the ref is a coordinated edit across the adoption record AND the workflow `@ref` lines.

## What this contract does NOT mandate

- Programming language, build tool, framework, test runner.
- Deploy pipeline beyond the universal-floor workflows named in [`ci-cd-standard.md`](ci-cd-standard.md).
- Which AI coding agent(s) the team uses — or whether they use any.
- Folder layout *inside* `docs/`, `.agents/skills/`, or `src/`.

The contract is about **structural alignment**, not implementation. Inside `docs/`, structure content however the product needs.

## Adoption

A new repo is brought into compliance by:

1. Copying [`../templates/consuming-repo/`](../templates/consuming-repo/) into the new repo and removing any vendor-adapter files for tools you don't use.
2. Filling in repo-specific names, owners, and links throughout.
3. Filling in [`security-first-adoption.md`](../templates/consuming-repo/security-first-adoption.md) — pinning the architecture-repo ref, declaring the deployment profile, listing any deviations.
4. Opening a dependency record in this repo's `portfolio/dependencies/` referencing the same architecture-repo ref.
5. Running the `repo-healthcheck` skill ([`../.agents/skills/repo-healthcheck/SKILL.md`](../.agents/skills/repo-healthcheck/SKILL.md)) and `pre-commit run --all-files`.

## Verification

- `repo-healthcheck` skill enforces the Universal Floor structurally.
- `validate-architecture.sh` enforces that this contract document and the standards/TeamOS docs that reference it do not bake vendor-specific files into the universal floor.
- `pre-commit` hooks (gitleaks, detect-secrets, file hygiene) run on every PR.
- `security-first-adoption.md`'s `upstream_ref:` field is checked by the consumer's CI to confirm the consumer is tracking a known architecture-repo ref.
