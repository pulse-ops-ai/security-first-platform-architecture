# docs/ — Index

Long-form documentation for this repo. Architecture concepts live in [`../architecture/`](../architecture/) and operating-model docs live in [`../team-os/`](../team-os/); `docs/` is for everything else.

## Sections

- [`product/INDEX.md`](product/INDEX.md) — product-level documentation (vision, scope, stakeholders)
- [`operations/INDEX.md`](operations/INDEX.md) — operational documentation (runbooks, on-call, conventions)
- [`decisions/INDEX.md`](decisions/INDEX.md) — Architecture Decision Records (ADRs)

## Conventions

- Every subdirectory has its own `INDEX.md`.
- ADRs are created from [`../templates/adr/ADR-template.md`](../templates/adr/ADR-template.md).
- Add new top-level subdirectories only after discussing with the platform team — the four-folder shape (`product`, `operations`, `decisions`, plus the section you propose to add) keeps navigation predictable across repos.
