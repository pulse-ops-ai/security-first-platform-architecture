# Dependency: <downstream-repo> depends on <upstream-repo> — <topic>

- **Opened:** YYYY-MM-DD
- **Status:** open | in_progress | resolved | cancelled
- **Downstream repo:** `<repo-name>`
- **Upstream repo:** `<repo-name>`
- **Owner downstream:** <name>
- **Owner upstream:** <name>

## What the dependency is

One paragraph describing the dependency in plain language.

## Upstream artifact

What specifically must the upstream repo deliver?

- **Type:** OpenSpec proposal | merged PR | published artifact (template / standard / skill) | architecture document
- **Reference:** path, PR link, OpenSpec proposal ID

## Unblock criteria

The dependency is `resolved` when:

- [ ] Upstream artifact is merged
- [ ] Downstream has verified the artifact in their integration tests
- [ ] (If applicable) ADR is updated to reflect the new state

## Timeline

- Earliest start (downstream): YYYY-MM-DD
- Target resolution: YYYY-MM-DD
- Hard deadline (if any): YYYY-MM-DD with rationale

## Cross-references

- Related OpenSpec proposals
- Related ADRs
- Related portfolio epic (if part of one)

## Notes

Anything else that future-you or another reviewer would want to know.
