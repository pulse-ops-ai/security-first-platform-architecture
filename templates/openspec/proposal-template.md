---
tier:                       # 1 | 2 | 3 — see ../../team-os/openspec-policy.md
status:                     # draft | in_review | accepted | rejected | withdrawn
completion_state:           # architecture-complete | adoption-complete
opened:                     # YYYY-MM-DD
target_decision_date:       # YYYY-MM-DD
authors:                    # list of GitHub handles
---

# OpenSpec Proposal: <Title>

## Problem

What is forcing this change? Describe the friction, gap, or incident. Be specific. A proposal whose problem statement could fit any change is too vague.

## Proposed change

State the change in one paragraph. The reader should be able to repeat it back without re-reading.

## Alternatives considered

For each serious alternative:

- **Name.**
- **Why considered.**
- **Why not chosen.**

A proposal with no alternatives is incomplete. If only one option was viable, say so explicitly and explain why.

## Impact

- **Repos affected:** list the consuming repos by name.
- **Layers / profiles affected:** which control layers and which profiles.
- **Standards affected:** which `standards/*.md` files change.
- **Templates affected:** which templates change.
- **Cross-repo contracts:** envelope claims, API shapes, observability schema, security boundaries, etc.
- **Security-boundary impact:** does this change any of Z0→Z4 crossings, identity, authorization, agent-as-client, or the internal envelope? If yes, flag it explicitly.

## Affected consumers (Tier 2/3 only)

One row per consumer. Bulk entries ("all consumers track this") are not allowed.

| Consumer repo | Affected artifact | Dependency record | Owner |
|---|---|---|---|
| `<repo-name>` | `<file or contract>` | [`<dep-id>`](../../portfolio/dependencies/<file>.md) | @handle |

If this row is empty for any consumer that the Impact section names, the proposal is incomplete.

## Migration plan + deprecation window

How do existing consumers move to the new state? Steps, ordering, deadlines.

- **`coordinated_landing_order:`** — `upstream-first` | `downstream-first` | `simultaneous` | `n/a`
- **`deprecation_window:`** — ISO 8601 date when the old pattern is no longer supported, or `n/a` for purely additive changes. Minimum window per [`../../team-os/cross-repo-governance.md`](../../team-os/cross-repo-governance.md): one consumer review-cadence cycle or 30 days, whichever is longer.
- **Migration steps:** numbered, with owner per step.

## Completion criteria

- **`completion_state:`** as declared in frontmatter.
- **`architecture-complete`** = architecture-repo PRs merged at the target ref; the new artifact is reachable. Consumers have not yet integrated.
- **`adoption-complete`** = all affected consumers have integrated and updated their `security-first-adoption.md`; the deprecation window has elapsed.
- Tier 3 proposals MUST target `adoption-complete`. Tier 2 proposals MAY target `architecture-complete` only when the change is purely guidance/documentation and does not require any consumer to act.

## Approval

- **Required reviewers:** platform team + leads from each affected consuming repo (named above).
- **Decision rule:** consensus among required reviewers, or platform lead tiebreaker for Tier 3.

## Linked artifacts

- `change.md` — concrete change spec.
- `tasks.md` — execution plan with completion-state matching.
- ADRs that will result (REQUIRED for Tier 3).
- Dependency records that will result — one per affected consumer (REQUIRED for Tier 2/3 with consumer impact).
