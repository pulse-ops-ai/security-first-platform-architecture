# Cross-Repo Governance

A change in one repository can block, enable, or invalidate work in another. The TeamOS makes those linkages **explicit and tracked** — never tribal knowledge.

## The three coordination artifacts

| Artifact | Lives in | Purpose |
|---|---|---|
| **Epic** | `portfolio/epics/` (architecture repo) | A multi-repo initiative with scope, owners, and target outcome |
| **Dependency record** | `portfolio/dependencies/` (architecture repo) | A directional dependency between two repos |
| **OpenSpec change** | `openspec/` in the repo where the change originates | A formal proposal for a governed change |

## When you need each

### You're starting a multi-repo initiative
→ Open an **Epic** in `portfolio/epics/`. List the involved repos, the architectural rationale, the target outcome, and a sequencing plan.

### Your repo's work depends on another repo
→ Add a **Dependency record** in `portfolio/dependencies/` naming the upstream repo, the artifact you depend on, and what unblocks you.

### You're changing an architecture document, standard, template, or `AGENTS.md`
→ Open an **OpenSpec proposal** in this repo. See [`openspec-policy.md`](openspec-policy.md).

### Your solution repo is making a non-trivial change that other repos may need to mirror
→ Open an OpenSpec proposal in your repo, and add a Dependency record here.

## How linkages block work

A dependency record can be in one of three states:

- **Open** — upstream work has not started. Downstream cannot proceed.
- **In progress** — upstream is actively delivering. Downstream may plan but not commit.
- **Resolved** — upstream artifact is available. Downstream can pull it in.

Healthcheck skills can list open dependencies pointing into a given repo, so coding agents and humans both have visibility into what's blocking the current PR.

## Roles

| Role | Responsibility |
|---|---|
| **Platform team** | Owns the architecture repo. Reviews Tier 2 / Tier 3 changes. Maintains epics and dependency records. |
| **Solution repo lead** | Owns a consuming repo. Acknowledges dependency records affecting their repo. Approves OpenSpec proposals that change their repo's contracts. |
| **Contributor** | Anyone making a change. Opens the right artifact and links it from the PR. |

## Conflict resolution

If two repos disagree on a contract, the architecture repo is the tiebreaker, but only by making the new rule explicit (OpenSpec → standard). The platform team does not adjudicate by email.

## Visibility

- The `portfolio/INDEX.md` is the index of all current epics and dependency records.
- Healthcheck skills surface mismatches between dependency records and reality (e.g., upstream merged but downstream record still open).
- Quarterly reviews check that epics are still real and dependency records are still load-bearing.
