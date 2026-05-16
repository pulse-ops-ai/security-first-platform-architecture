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

Coding agents are typically launched inside **one** of these directories at a time. The sibling layout means cross-repo lookups (greps, dependency record reads, sibling-repo inspections) are cheap when needed.

## Why sibling, not monorepo

- Each solution repo has its own release cadence, owners, CI policies, and possibly its own customers.
- Mono-repo tooling adds friction without proportional benefit at this scale.
- A separate architecture repo keeps the standards visibly distinct from any one product.

## Why sibling, not unrelated

- Architecture changes affect consuming repos. A flat workspace makes those linkages tractable.
- Cross-repo dependency records (see [`cross-repo-governance.md`](cross-repo-governance.md)) reference paths under this layout.
- Agent skills (e.g., cross-repo impact review) can traverse sibling repos when invoked from the architecture repo.

## The architecture repo's role

- **Source of truth** for `AGENTS.md`, standards, templates, and architecture documents.
- **Adoption kit** for new and existing solution repos.
- **Coordination point** for cross-repo work via the `portfolio/` folder.

Consuming repos **do not** copy this repo. They **adopt** it (by name, by template snapshot, or by Git ref) and record the adoption in their own `security-first-adoption.md` (see the [repo contract](../standards/repo-contract.md)).

## What consuming repos must have

The canonical list lives in [`../standards/repo-contract.md`](../standards/repo-contract.md). The contract distinguishes:

- the **universal floor** — files every consuming repo MUST have regardless of tooling, and
- **vendor-specific adapter files** — required only when that tool is in use.

Do not restate the floor here; the contract is the source of truth and is what the validators check against.

## Bootstrapping a new solution repo

1. Clone it as a sibling under `~/work/security-first-platform/`.
2. Copy `templates/consuming-repo/*` into the new repo.
3. Fill in repo-specific names, owners, and links.
4. Fill in `security-first-adoption.md` — the adoption record that pins which architecture-repo ref this consumer tracks.
5. Open a dependency record back to the architecture repo: see [`../templates/dependency-record/dependency-template.md`](../templates/dependency-record/dependency-template.md).
6. Run the healthcheck skills.

## What this is not

- Not a Bazel/Pants/Nx workspace. There is no shared build system.
- Not a Git submodule layout. Each repo is independent and pinned by ref rather than vendored.
- Not a guarantee about cross-repo CI. Each repo's CI clones what it needs explicitly; the sibling layout is for **local** developer and agent ergonomics. Workflows that need cross-repo context (e.g., a `cross-repo-impact-review` job) check out the relevant sibling on demand via `actions/checkout` with an explicit `repository:` input.
