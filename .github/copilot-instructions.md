# GitHub Copilot Instructions

This file is the GitHub Copilot adapter for this repository. The source of truth is [`../AGENTS.md`](../AGENTS.md) and the indexes it references. If this file ever conflicts with `AGENTS.md`, follow `AGENTS.md`.

## Pull Request Review

- Treat this repository as the security-first platform architecture and TeamOS source of truth. Do not ask for application code, runtime scaffolding, or product implementation unless the PR explicitly changes templates for consuming repos.
- Start from [`../AGENTS.md`](../AGENTS.md), then read the relevant `INDEX.md` files before reviewing specific documents.
- Prioritize review findings that affect security boundaries, architecture correctness, cross-repo contracts, governance, secrets handling, CI safety, or documentation navigation.
- Check that new, renamed, or removed Markdown files are reflected in the relevant `INDEX.md` files.
- Check that vendor-specific content stays in `architecture/profiles/` or `infra/profiles/`; vendor-neutral architecture docs must remain implementation-neutral.
- Check that reference infrastructure contains examples only: no live secrets, tenant IDs, account IDs, production state, or deploy credentials.
- For `.github/`, CI, or CODEOWNERS changes, apply the review procedure in [`../.agents/skills/github-enterprise-ci-review/SKILL.md`](../.agents/skills/github-enterprise-ci-review/SKILL.md).
- For security-stack or trust-boundary changes, apply the review procedure in [`../.agents/skills/security-control-review/SKILL.md`](../.agents/skills/security-control-review/SKILL.md).
- For standards, templates, `AGENTS.md`, or TeamOS changes, check whether the OpenSpec policy requires a proposal before merge.
- Keep comments actionable and focused on defects or missing required evidence. Avoid commenting when the change is already consistent with the repo contract.
