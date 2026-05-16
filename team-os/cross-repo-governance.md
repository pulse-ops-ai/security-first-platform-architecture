# Cross-Repo Governance

A change in one repository can block, enable, or invalidate work in another. The TeamOS makes those linkages **explicit and tracked** — never tribal knowledge.

## The three coordination artifacts

| Artifact | Lives in | Purpose |
|---|---|---|
| **Epic** | `portfolio/epics/` (architecture repo) | A multi-repo initiative with scope, owners, and target outcome |
| **Dependency record** | `portfolio/dependencies/` (architecture repo) | A directional dependency between two repos with a pinned upstream ref |
| **OpenSpec change** | `openspec/` in the repo where the change originates | A formal proposal for a governed change (see [`openspec-policy.md`](openspec-policy.md)) |

A fourth, **the consuming repo's adoption record** (`security-first-adoption.md`), is the consumer-side mirror of the dependency records that affect that repo.

## When you need each

### You're starting a multi-repo initiative
→ Open an **Epic** in `portfolio/epics/`. List the involved repos, the architectural rationale, the target outcome, and a sequencing plan.

### Your repo's work depends on another repo
→ Add a **Dependency record** in `portfolio/dependencies/` populated with the schema in [`../templates/dependency-record/dependency-template.md`](../templates/dependency-record/dependency-template.md). Mirror the record under `cross_repo_dependencies:` in your repo's `security-first-adoption.md`.

### You're changing an architecture document, standard, template, skill, CI gate, security boundary, or `AGENTS.md` in this repo
→ Open an **OpenSpec proposal** in this repo. Tier rules in [`openspec-policy.md`](openspec-policy.md).

### Your solution repo is making a non-trivial change that other repos may need to mirror
→ Open an OpenSpec proposal in your repo, and add a Dependency record here pointing the affected sibling consumers at the upcoming change.

## Pinning — how consumers track the architecture

Consumers do **not** track `main` of this repo. They pin.

- Every consuming repo records the architecture-repo ref it currently follows in `security-first-adoption.md` under `architecture_ref:` and `architecture_ref_kind:` (one of `sha`, `tag`, `branch`).
- Tag pins are the recommended default for production consumers. SHA pins are acceptable for short-lived experiments. Branch pins are discouraged outside of integration testing.
- Moving a consumer to a new ref is itself a Tier 2 change in that consumer's repo: open an OpenSpec proposal in the consumer, update `architecture_ref`, and confirm `pending_openspec_changes:` is empty before the move.
- A dependency record's `upstream_ref:` field names the **target** ref the dependency drives the consumer toward — usually a ref ahead of the consumer's current pin.

## Transitive dependencies

When A → B → C (A depends on B, B depends on C), a contract change in C can propagate to A even if A has no direct relationship with C.

Rule:

- B is responsible for **forwarding the impact** to A when a C-change affects B's contract surface with A.
- B forwards by opening a dependency record from A → B that references the upstream C → B dependency record. The forwarded record is its own artifact, not a comment on the C record.
- A is not required to track C directly. A tracks B's adoption record.
- If a Tier 3 change in C cascades to A through B, the cascade chain MUST be drawn explicitly in the C-side OpenSpec proposal's "Impact" section.

## Coordinated landing

A dependency record's `coordinated_landing_order:` field declares the merge order:

| Value | Meaning |
|---|---|
| `upstream-first` | Upstream merges first; downstream integrates within the deprecation window. Default for additive changes. |
| `downstream-first` | Downstream prepares (e.g., adds a feature flag) before upstream lands. Rare; use when upstream's change would break downstream on day one without prep. |
| `simultaneous` | Both PRs merge in lockstep, typically because the change is a breaking contract swap with no coexistence window. Requires explicit named owners on both sides. |
| `n/a` | No coordination needed — the change is internal to upstream. |

A `simultaneous` landing requires the related OpenSpec proposal to list both PRs as completion criteria. Neither side may merge without the other being ready.

## Deprecation windows

A "deprecation window" is the period during which the old and new behaviors must **both** be supported, giving consumers time to migrate.

Rule:

- Any Tier 2/3 change that supersedes an existing pattern MUST declare a `deprecation_window:` in the related dependency records.
- The minimum window is **one consumer review cadence cycle** (see each consumer's `review_cadence:` in `security-first-adoption.md`) or 30 days, whichever is longer.
- The architecture repo MUST keep both the old and the new artifact reachable (by ref) for the duration of the window. Removing the old artifact before the window closes is itself a Tier 3 change requiring its own proposal.
- During the window, the related OpenSpec proposal status is `accepted` but not `complete`. It moves to `complete` when the window closes AND every affected consumer has either integrated or has an active deviation record.

## Multi-repo completion — what "done" means

Tier 2/3 OpenSpec proposals have two distinct completion states:

| State | Meaning |
|---|---|
| **architecture-complete** | The architecture-repo PR has merged. The new contract / standard / template / skill is reachable at a stable ref. Consumers have *not yet* integrated. |
| **adoption-complete** | All affected consumers have integrated and updated their `security-first-adoption.md`. The deprecation window (if any) has elapsed. The proposal is fully closed. |

Proposals declare which state they target in their `tasks.md`. A proposal that only intends to ship architecture-side guidance can complete at `architecture-complete`; a proposal that swaps a contract MUST reach `adoption-complete` before the old artifact is removed.

## Dependency-record linkage rule

A Tier 2/3 OpenSpec proposal in this architecture repo that has downstream impact MUST link **one dependency record per affected consumer** by the time the proposal reaches `accepted`. Bulk records ("all consumers track this") are not allowed — each consumer's record is the authoritative artifact for that consumer's integration.

The `openspec-change-triage` skill enforces this; CI runs it on Tier 2/3 proposal changes.

## How linkages block work

A dependency record can be in one of four states:

- **Open** — upstream work has not started. Downstream cannot proceed.
- **In progress** — upstream is actively delivering. Downstream may plan but not commit.
- **Resolved** — upstream artifact is available; downstream has integrated. Record is closed but kept for audit.
- **Cancelled** — dependency no longer applies. Record is closed with reason.

The `cross-repo-impact-review` skill lists open and in-progress dependencies pointing into a given repo so reviewers know what's blocking the current PR.

## Roles

| Role | Responsibility |
|---|---|
| **Platform team** | Owns the architecture repo. Reviews Tier 2/3 changes. Maintains epics, dependency records, and the deprecation calendar. |
| **Solution repo lead** | Owns a consuming repo. Acknowledges dependency records affecting their repo. Approves OpenSpec proposals that change their repo's contracts. Owns their `security-first-adoption.md`. |
| **Contributor** | Anyone making a change. Opens the right artifact, links it from the PR, populates the dependency-record schema fully. |

## Conflict resolution

If two repos disagree on a contract, the architecture repo is the tiebreaker, but only by making the new rule explicit (OpenSpec → standard). The platform team does not adjudicate by email.

## Visibility

- `portfolio/INDEX.md` is the index of all current epics and dependency records.
- `cross-repo-impact-review` skill surfaces mismatches between dependency records and reality (e.g., upstream merged but downstream record still open).
- Quarterly reviews check that epics are still real, dependency records are still load-bearing, and consumer `security-first-adoption.md` records are current.
