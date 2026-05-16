# OpenSpec Change: <Title>

Companion to `proposal.md`. The proposal answers *why and what*; this file answers *concretely what files and contracts change*.

## Files changed

For each file:

- **Path.**
- **Before / After.** Snippet, signature, or contract that shows the change.
- **Rationale.** Why this specific edit.

## Contract changes

If this change affects any cross-component contract, document each:

### Contract: <name>

- **Type:** internal envelope claim | API shape | observability field | other
- **Before:** schema or signature
- **After:** schema or signature
- **Versioning strategy:** additive | breaking | deprecation window
- **Verification:** how downstream verifies the new contract

## Cross-repo migration steps

| Repo | Step | Status |
|---|---|---|
| <repo-a> | <action> | pending |
| <repo-b> | <action> | pending |

## Rollback

How is this change rolled back if the migration fails partway through? If rollback is impractical, say so and document the compensating safeguards.

## Verification

- Tests, healthchecks, or observability changes that prove the new state.
- Skill runs that should pass after this change.
