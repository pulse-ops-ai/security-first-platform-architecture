---
# Dependency record — required schema.
#
# Every field is REQUIRED. Leave a field as "n/a" if it truly does not
# apply; do not omit the key. Validators check field presence, not values.

dependency_id:                # e.g., DEP-2026-05-20-001 — stable, never reused
title:                        # one-line, human-readable
upstream_repo:                # repo name (e.g., security-first-platform-architecture)
upstream_ref:                 # SHA / tag / branch that this dependency targets
upstream_ref_kind:            # one of: sha | tag | branch
upstream_artifact:            # specific file or contract (e.g., architecture/internal-identity-envelope.md)
downstream_repo:              # consumer repo name (e.g., trupryce)
downstream_artifact:          # specific file or component in the downstream repo affected
dependency_type:              # one of: contract | template | standard | skill | profile | security-boundary | other
impact_tier:                  # one of: 2 | 3   (Tier 1 dependencies don't need a record)
status:                       # one of: open | in_progress | resolved | cancelled
blocking_direction:           # one of: blocks-downstream | blocks-upstream | bidirectional
required_by:                  # ISO 8601 — when downstream needs upstream resolved
deprecation_window:           # n/a OR ISO 8601 — date the old pattern is no longer supported
coordinated_landing_order:    # one of: upstream-first | downstream-first | simultaneous | n/a
owner:                        # GitHub handle responsible for closing this record
opened_date:                  # ISO 8601
resolved_date:                # ISO 8601 or blank
related_openspec_proposal:    # URL or path to the OpenSpec proposal driving this dependency
notes:                        # free text — keep brief; long context goes in the prose section below
---

# Dependency: <downstream-repo> depends on <upstream-repo> — <topic>

## What the dependency is

<!-- One paragraph. What concretely does upstream need to deliver, and what concretely does downstream need to absorb? -->

## Upstream artifact

<!-- Describe the contract, file, or behavior. Link to the OpenSpec proposal driving the change. -->

## Downstream impact

<!-- What in the downstream repo changes? Which files, modules, or runtime components are affected? Estimate effort. -->

## Unblock criteria

The dependency moves to `resolved` when ALL of:

- [ ] Upstream artifact is merged at the ref recorded in `upstream_ref`
- [ ] Downstream integration is merged (or, for `architecture-complete` Tier 2 proposals, downstream has acknowledged in their adoption record)
- [ ] Downstream `security-first-adoption.md` updated to reflect the new state
- [ ] (If applicable) ADR linked from this record

## Coordinated landing

<!-- Describe the merge order if it matters. For `upstream-first`: upstream merges first, downstream integrates within the deprecation window. For `simultaneous`: typically requires multi-PR coordination via the related OpenSpec proposal. Document the exact sequence and who is on the hook for each step. -->

## Deprecation window

<!-- If `deprecation_window` is set, explain what the OLD behavior is, what the NEW behavior is, and what consumers must do during the coexistence window. If `deprecation_window` is `n/a`, state why no coexistence is needed (e.g., the change is purely additive). -->

## Cross-references

- Related OpenSpec proposal: <link or path>
- Related ADRs: <list>
- Related portfolio epic (if any): <link>
- Consumer adoption record entry: link to the relevant section in the downstream repo's `security-first-adoption.md`

## Notes

<!-- Anything else a future reviewer or auditor would want to know. Surface decisions about scope, sequencing, or risks. -->
