---
tier: 2
status: accepted
completion_state: architecture-complete
opened: 2026-05-17
target_decision_date: 2026-05-24
accepted_date: 2026-05-16
archived_date: 2026-05-16
merged_pr: 11
authors:
  - "@mike"
---

# OpenSpec Proposal: Audience-Tiered Navigation

## Problem

The repo currently has a single navigation surface (`README.md`'s "How to navigate" table) that mixes audiences. ADRs are reachable but unadvertised — a stakeholder or security auditor landing on the README cannot find the foundational decisions without already knowing they exist.

Concretely:

- `README.md` does not link to `docs/decisions/`. The trade-off record for the eight-layer model, agent-as-client rule, and internal envelope is three hops away from the front door.
- Architecture docs (`architecture/control-layers.md`, `architecture/agent-as-client-model.md`, `architecture/internal-identity-envelope.md`) describe the *what* without linking to the ADR that captures the *why*.
- There is no product entry point. `docs/product/INDEX.md` is a stub. A stakeholder asking "what does this repo promise" has no answer surface.
- `AGENTS.md`'s "Where to find things" table doesn't surface `docs/decisions/` either.
- The implicit audience split (engineers go to `architecture/`, operators go to `docs/operations/`, agents go to `AGENTS.md`) is not represented in `README.md`. Audiences self-discover their entry point or don't.

Acceptance discussion in [PR #10](https://github.com/pulse-ops-ai/security-first-platform-architecture/pull/10) flagged this as **important now** — before the first consumer onboards, before the first audit conversation, before adding more ADRs that would compound the discoverability gap.

## Proposed change

Adopt an **audience-tiered top-level navigation** with six entry points, surfaced from a thin `README.md` landing page:

| Audience | Entry point |
|---|---|
| Product / stakeholder | `docs/product/INDEX.md` |
| Engineering | `architecture/INDEX.md` |
| Operations | `docs/operations/INDEX.md` |
| Foundational decisions / audit | `docs/decisions/INDEX.md` |
| Coding agents | `AGENTS.md` |
| Security reports | `SECURITY.md` |

Concrete edits:

1. **`README.md`** becomes a thin router. Keep the motto, one-paragraph description, and the audience-routing table. Drop the duplicated "Core thesis", "Workspace model", "Agents", "Governance" sections — those readers now go to the appropriate entry point.
2. **`docs/product/INDEX.md`** gets real content: what the repo promises, what it doesn't promise, who owns it, where decisions are recorded, how consumers adopt, current adoption state.
3. **`architecture/INDEX.md`** gains a "Related decisions" section linking to the three ADRs.
4. **`architecture/control-layers.md`**, **`agent-as-client-model.md`**, **`internal-identity-envelope.md`** each get a `> See ADR-NNNN for the trade-off record.` callout near the top.
5. **`AGENTS.md`**'s "Where to find things" table adds a row for `docs/decisions/INDEX.md`.
6. **`CLAUDE.md`** "Read first" list adds `docs/decisions/INDEX.md`.
7. **`docs/INDEX.md`** keeps its current shape (it's the `docs/` tree's own index, not an audience entry).
8. **`docs/product/INDEX.md`** also serves as a placeholder the first consumer onboarding session will extend with the live adoption state.

## Alternatives considered

- **Small fix.** Add a single row to `README.md` and `AGENTS.md` pointing at `docs/decisions/`, plus cross-link the three architecture docs to their ADRs. Rejected: solves the ADR discoverability problem but doesn't address the absence of a product entry point. Stakeholders still have no answer surface. The user explicitly asked for the Large option after weighing the trade-offs.
- **Medium fix.** Small + populate `docs/product/INDEX.md`. Rejected: leaves `README.md` as a mixed-audience surface, which doesn't deliver the audience-tiered navigation the question asked for.
- **Rename `architecture/` to `docs/engineering/`.** Considered for consistency with `docs/product/`, `docs/operations/`, `docs/decisions/`. Rejected: would break every cross-reference in every existing doc and every consumer's planned link. `architecture/` is a top-level concern of this repo (literally in the repo name) and deserves to live at the root, not under `docs/`. The router prose explains the asymmetry.
- **Do nothing yet, wait for the first auditor or consumer to push.** Considered. Rejected after user feedback explicitly classified this as important *now* — before the first consumer onboards, fixing this is cheap; after, every consumer's `security-first-adoption.md` will reference a discoverability path we then have to migrate.

## Impact

- **Repos affected:** the architecture repo only.
- **Layers / profiles affected:** none.
- **Standards affected:** none.
- **Templates affected:** none.
- **Cross-repo contracts:** none.
- **Security-boundary impact:** none directly. The change *strengthens* the discoverability of security-relevant ADRs (agent-as-client rule, envelope trust mechanism) but does not change any control-layer behavior or boundary.

## Note on tier classification (script vs intent)

`scripts/openspec-triage.sh` classifies this PR as **Tier 3** because the diff touches `architecture/agent-as-client-model.md` and `architecture/internal-identity-envelope.md`, both in the script's Tier-3 path list. The script is path-based; it cannot distinguish a contract change from a navigation callout.

The actual diff in those two files is a single blockquote near the top:

```
> See [`ADR-NNNN`](../docs/decisions/ADR-NNNN-…) for the trade-off record — …
```

That is pure cross-linking. No envelope claim, no agent rule, no trust-zone semantics change.

This proposal therefore declares `tier: 2` to match the *intent* of the change. The triage script PASSes (it doesn't BLOCK on tier-mismatch between diff and proposal), so CI is unblocked, but the proposal/script verdicts are technically inconsistent.

The same over-classification pattern was acknowledged in PR-3 for the `scripts/*` rule. A future PR could tighten `is_tier3_file` (or add a sibling `is_navigation_only_diff` helper) to recognize "additive blockquote near the top, no other content change" as Tier 2 even when the file is in the Tier 3 list. Captured as a known limitation; not done in this PR to keep scope focused on the navigation restructure.

If the team prefers strict adherence to the script's verdict, the alternative is to drop the per-doc ADR callouts and keep only the `## Related decisions` section in `architecture/INDEX.md`. That keeps the change inside `architecture/*.md` (Tier 2) without touching the Tier-3-listed files, at the cost of meaningfully worse in-doc discoverability for the reader who lands on `control-layers.md` directly.

## Affected consumers (Tier 2/3 only)

| Consumer repo | Affected artifact | Dependency record | Owner |
|---|---|---|---|
| _(none — pure architecture-repo navigation change)_ | n/a | n/a | n/a |

`completion_state: architecture-complete`. No consumer action required. Future consumer `security-first-adoption.md` records will use the new entry points; existing references to `README.md` continue to work (the file is restructured, not deleted).

## Migration plan + deprecation window

- **`coordinated_landing_order:`** `n/a`
- **`deprecation_window:`** `n/a` — no pattern is superseded. The old `README.md` content is *restructured*, not removed; the audience-specific surfaces (product, decisions) are *added*, not replaced.
- **Migration steps:**
  1. Merge this PR.
  2. The next PR that wants to add stakeholder-facing content adds it to `docs/product/`, not the README.
  3. The next consumer onboarding (e.g., `trupryce`) references `docs/product/INDEX.md` in its `security-first-adoption.md` as the entry point for product-level adoption questions.

## Completion criteria

`completion_state: architecture-complete`

- `README.md` restructured to thin landing page.
- `docs/product/INDEX.md` populated with real content.
- ADR cross-links present in `architecture/INDEX.md` and the three foundational architecture docs.
- `AGENTS.md` and `CLAUDE.md` surface `docs/decisions/`.
- All validators pass.
- No consumer action required.

## Approval

- **Required reviewers:** platform team.
- **Decision rule:** platform-team consensus.

## Linked artifacts

- [`change.md`](change.md) — concrete file diffs
- [`tasks.md`](tasks.md) — execution plan
- No ADRs (Tier 2)
- No dependency records (no consumer impact)
- PR #10 discussion — origin of the "Large" decision
