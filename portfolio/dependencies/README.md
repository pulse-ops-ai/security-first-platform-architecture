# Dependencies

A **dependency record** is a directional dependency from one repo to another, captured here so that everyone — humans and agents — can see what is blocked, by what, and on whom.

See [`../../team-os/cross-repo-governance.md`](../../team-os/cross-repo-governance.md) for the rules. See [`../../templates/dependency-record/dependency-template.md`](../../templates/dependency-record/dependency-template.md) for the template.

## When to open a dependency record

- Your repo's planned work depends on a change in another repo.
- An OpenSpec change in another repo will require your repo to migrate.
- A standard or template change here will require updates in consuming repos.

If the dependency is a single line in a PR description, it does not need a record. If it spans more than a week or more than a couple of PRs, write a record.

## File naming

`YYYY-MM-DD-<downstream-repo>-depends-on-<upstream-repo>-<topic>.md`

Examples:

- `2026-05-20-trupryce-depends-on-architecture-envelope-claims.md`
- `2026-06-01-findevil-depends-on-levelup-platform-tenant-api.md`

## Lifecycle

| Status | Meaning |
|---|---|
| `open` | Upstream work has not started |
| `in_progress` | Upstream is actively delivering |
| `resolved` | Upstream artifact is available; downstream can pull it in |
| `cancelled` | Dependency no longer applies |

A `resolved` or `cancelled` record stays in this folder for audit / search.

## Current dependency records

_None yet._
