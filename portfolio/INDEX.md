# portfolio/ — Index

Cross-repo coordination lives here. See [`../team-os/cross-repo-governance.md`](../team-os/cross-repo-governance.md) for the rules.

## Sections

- [`epics/`](epics/) — multi-repo initiatives ([`epics/README.md`](epics/README.md))
- [`dependencies/`](dependencies/) — directional repo-to-repo dependencies ([`dependencies/README.md`](dependencies/README.md))

## How this index is used

Coding agents and humans use this folder to answer:

- "What multi-repo work is currently in flight?"
- "Is my repo blocked by upstream work in another repo?"
- "Which solution repos are affected by the standard I'm about to change?"

The `cross-repo-impact-review` skill ([`../.agents/skills/cross-repo-impact-review/SKILL.md`](../.agents/skills/cross-repo-impact-review/SKILL.md)) consumes this folder.

## Current portfolio

- Epics: _none yet_
- Dependencies:
  - `DEP-2026-05-25-trupryce` — trupryce → architecture @ `v0.1.0`, `resolved` (2026-05-27). [Record](dependencies/2026-05-25-trupryce-depends-on-security-first-platform-architecture-onboarding.md).
  - `DEP-2026-05-24-001` — platform-edge → architecture @ `v0.2.0` (bumped `v0.1.0` → `v0.1.1` 2026-05-28 after consumer-mode hotfix, → `v0.2.0` 2026-05-29 for the diagramming kit), `resolved` (2026-05-29). [Record](dependencies/2026-05-24-platform-edge-depends-on-security-first-platform-architecture-onboarding.md).
  - `DEP-2026-06-07-001` — platform-edge → **infra-auth** (Keycloak issuer for L3 edge identity; `https://auth.trupryce.ai`, realm `trupryce-prod`), `open`. Driven by platform-edge's step-2 L3 OpenSpec proposal. [Record](dependencies/2026-06-07-platform-edge-depends-on-infra-auth-keycloak.md).
