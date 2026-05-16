# Dependencies

A **dependency record** is a directional, schema-validated dependency from one repo to another, captured here so that humans and agents can see what is blocked, by what, and on whom.

Rules and lifecycle live in [`../../team-os/cross-repo-governance.md`](../../team-os/cross-repo-governance.md). Schema lives in [`../../templates/dependency-record/dependency-template.md`](../../templates/dependency-record/dependency-template.md). This README only catalogs what's open.

## When to open a dependency record

- A Tier 2 or Tier 3 OpenSpec proposal in this repo has downstream impact → one record **per affected consumer**.
- Your repo's planned work depends on a change in another repo that's more than a one-line PR comment.
- A standard, template, or contract change here will require updates in consuming repos.

Tier 1 changes do not need a dependency record. If you're unsure of the tier, the `openspec-change-triage` skill decides.

## File naming

`YYYY-MM-DD-<downstream-repo>-depends-on-<upstream-repo>-<topic>.md`

The filename must match the `dependency_id:` in the frontmatter's date component.

Examples:

- `2026-05-20-trupryce-depends-on-architecture-envelope-claims.md`
- `2026-06-01-findevil-depends-on-levelup-platform-tenant-api.md`

## Required fields

Every record uses the schema from [`../../templates/dependency-record/dependency-template.md`](../../templates/dependency-record/dependency-template.md). The required-fields contract:

- `dependency_id`, `title`, `upstream_repo`, `upstream_ref`, `upstream_ref_kind`, `upstream_artifact`
- `downstream_repo`, `downstream_artifact`
- `dependency_type`, `impact_tier`, `status`, `blocking_direction`
- `required_by`, `deprecation_window`, `coordinated_landing_order`
- `owner`, `opened_date`, `resolved_date`, `related_openspec_proposal`, `notes`

`upstream_ref` is the **target** ref the consumer is being driven toward. The consumer's current ref lives in its own `security-first-adoption.md`.

## Lifecycle

| Status | Meaning |
|---|---|
| `open` | Upstream work has not started |
| `in_progress` | Upstream is actively delivering |
| `resolved` | Upstream merged at `upstream_ref` AND downstream has integrated AND downstream `security-first-adoption.md` updated |
| `cancelled` | Dependency no longer applies (record kept with reason) |

A `resolved` or `cancelled` record stays in this folder for audit / search. Do not delete records.

## Transitive cascades

When A depends on B and B depends on C, B is responsible for forwarding the impact to A by opening an A→B record that references the C→B record. See [`../../team-os/cross-repo-governance.md`](../../team-os/cross-repo-governance.md) §Transitive dependencies.

## Coordinated landing

Each record declares a `coordinated_landing_order:`. The four legal values (`upstream-first`, `downstream-first`, `simultaneous`, `n/a`) are defined in the governance doc. `simultaneous` landings require both PRs as completion criteria in the related OpenSpec proposal.

## Current dependency records

_None yet._
