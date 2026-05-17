# docs/operations/ — Index

Operational documentation for this repo: how to maintain the architecture, how to run the validation skills, how to onboard a new consuming repo, etc.

## What lives here

- Maintainer playbooks
- Onboarding guide for new consuming repos
- How to run the validation scripts in [`../../scripts/`](../../scripts/)
- Release / tagging conventions if/when introduced

## Documents

- [`branch-protection.md`](branch-protection.md) — desired branch-protection state for `main` and the `gh api` commands to apply or audit it. Not code-enforced; this is the operational runbook.
- [`first-consumer-onboarding.md`](first-consumer-onboarding.md) — step-by-step walkthrough for bringing the first (or any) consuming repo into the architecture. Pre-reqs, the 11 steps from template-copy through first-PR, post-onboarding cadence, common issues, and where to get help. Worked example uses `trupryce` at decision points.
