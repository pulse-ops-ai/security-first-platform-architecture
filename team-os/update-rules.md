# Update Rules

The TeamOS is a living operating system. It must evolve as the team learns — but not faster than it can be consistently adopted.

## When to update

Update the TeamOS when:

1. A recurring friction surfaces that a small change would eliminate.
2. A new agent or tool joins the workflow and the contract needs to acknowledge it.
3. A standard or template no longer matches reality in the consuming repos.
4. An incident or near-miss reveals an implicit assumption that should be explicit.

Do **not** update the TeamOS to capture one-off preferences or single-conversation decisions. Those belong in PR descriptions or ADRs, not in `team-os/`.

## How to update

Updates fall into three tiers:

### Tier 1 — Documentation refinement

Wording, examples, link fixes, removing duplication.

- Normal PR.
- No OpenSpec change required.
- One reviewer from the platform team.

### Tier 2 — New or changed standard

Adding/modifying a file in `standards/`, changing a template, changing what `AGENTS.md` requires.

- **OpenSpec proposal required.** See [`openspec-policy.md`](openspec-policy.md).
- Notify consuming repos via a dependency record so they can plan adoption.

### Tier 3 — Architecture change

A change to the eight control layers, the agent-as-client rule, the security boundary model, or any principle.

- **OpenSpec proposal required.**
- ADR required ([`../templates/adr/ADR-template.md`](../templates/adr/ADR-template.md)) in [`../docs/decisions/`](../docs/decisions/).
- Migration plan for consuming repos.
- Healthcheck workflows updated to reflect the new rule.

## Backwards compatibility

The TeamOS makes a soft promise: **consuming repos do not have to adopt every change immediately**. They adopt at PR cadence. The architecture repo signals what is required by *new* work and what is recommended for existing work.

Hard-breaking changes (e.g., the agent-as-client rule itself) come with explicit migration windows and tooling.

## Versioning

- The architecture repo is **not** semver-versioned. Consuming repos pin against a Git SHA or tag if they need a snapshot.
- Each Tier 2 / Tier 3 change is tagged.
- A `CHANGELOG.md` may be added at the repo root once changes start landing.

## Who can propose

Anyone in the org. Acceptance requires the platform team and (for Tier 3) at least one engineering lead from each currently-active consuming repo, per [`cross-repo-governance.md`](cross-repo-governance.md).
