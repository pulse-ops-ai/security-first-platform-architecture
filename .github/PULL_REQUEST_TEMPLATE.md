# Summary

<!-- 1–3 sentences. What changes and why. -->

## Tier classification

This PR is **Tier**:

- [ ] **1** — local docs or non-contractual cleanup (typo / link / additive opt-in skill / formatting). No OpenSpec needed.
- [ ] **2** — repo contract, standard, template, skill, CI gate, OpenSpec, or architecture behavior. OpenSpec proposal required.
- [ ] **3** — cross-repo architecture or security-boundary change. OpenSpec proposal + ADR required, targets `adoption-complete`.

Tier definitions: [`team-os/openspec-policy.md`](../team-os/openspec-policy.md). If unsure, run the `openspec-change-triage` skill.

## OpenSpec (Tier 2/3 only)

- OpenSpec proposal: <link, or "n/a — Tier 1">
- `completion_state:` — `architecture-complete` | `adoption-complete`
- `deprecation_window:` — ISO 8601 date, or "n/a — purely additive"
- `coordinated_landing_order:` — `upstream-first` | `downstream-first` | `simultaneous` | `n/a`

## Cross-repo impact

- [ ] No consumers are affected.
- [ ] Consumers are affected — listed below with a dependency record per consumer.

| Consumer repo | Affected artifact | Dependency record |
|---|---|---|
|  |  |  |

## Adoption-record impact (Tier 2/3 with consumer impact)

For each affected consumer:

- [ ] The consumer's `security-first-adoption.md` will be updated as part of this change (or in a follow-up PR linked in the dependency record).
- [ ] The consumer's `architecture_ref:` will move to the ref this PR introduces — and the consumer team is aware.

## Security boundary impact

- [ ] None. This PR does not touch identity, authorization, network admission, internal envelope, agent-as-client behavior, multi-tenancy, or audit emission.
- [ ] Yes — described below. Apply the `security-control-review` skill.

<!-- If yes, describe the trust-zone crossings affected, the new evidence required, and how the change fails closed. -->

## Notion / external-context impact

- [ ] No long-form context changed.
- [ ] Long-form context changed — Notion updated via the `push-to-notion` skill, link below.

<!-- Notion link, if applicable -->

## Validation

Confirm each command ran clean locally:

- [ ] `bash scripts/validate-skills.sh`
- [ ] `bash scripts/sync-agent-skills.sh --check`
- [ ] `bash scripts/validate-architecture.sh`
- [ ] `bash scripts/validate-doc-indexes.sh`
- [ ] `pre-commit run --all-files`

## Reviewer-attention checklist

- [ ] No live secrets, real account IDs, tenant identifiers, or production tfstate in the diff.
- [ ] No vendor names leaked into neutral architecture or TeamOS prose (vendor names belong in `architecture/profiles/` or `infra/profiles/`).
- [ ] `INDEX.md` files updated alongside any added/renamed/removed `.md` file.
- [ ] CODEOWNERS reviewers requested per the touched paths.

🤖 Generated with the security-first-platform-architecture PR template.
