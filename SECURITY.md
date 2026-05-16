# Security Policy

This repository — `security-first-platform-architecture` — is a public reference architecture and TeamOS adoption kit. It contains **no runtime code, no live deployments, and no live secrets**.

That said, scaffold-level vulnerabilities matter: a flawed reference can propagate into many consuming repos. This file describes how to report security issues and what is in scope.

## Reporting a vulnerability

Send a private report to **`security@pulseops.ai`** _(TODO: confirm this mailbox is monitored. Until confirmed, also open a private security advisory via GitHub Security Advisories on this repository.)_

Include:

- A short description of the issue.
- A reproducer or a pointer to the affected file/path.
- Your assessment of impact (e.g., "would propagate to all consuming repos" vs "affects only this repo").
- Whether you've shared the report with anyone else.

**Please do not open a public GitHub issue, public PR, or social-media thread before we have acknowledged the report.** Coordinated disclosure protects consuming repos that depend on this scaffold.

### Response expectations

- Acknowledgement within **3 business days**.
- Triage and severity classification within **7 business days**.
- For confirmed issues affecting consuming repos: a private heads-up to the affected solution-repo leads while a fix is developed.
- Disclosure timeline negotiated with the reporter; default 90 days from acknowledgement to public disclosure.

## In scope

Reports are welcome for, and should be treated as security issues in, this repo:

- **Leaked secrets** — any credentials, API keys, tokens, certificates, or PII committed to this repo.
- **Insecure templates** — templates under `templates/` or `infra/profiles/` that would, when adopted, produce insecure consuming repos. Examples: a template that disables TLS verification, omits authentication, or hard-codes a weak credential pattern.
- **Unsafe CI/CD guidance** — workflows or hooks under `.github/workflows/` or `scripts/` that would, when adopted by a consuming repo, weaken its security posture (e.g., disable a check, suppress a finding, use long-lived deploy credentials).
- **Broken security-boundary guidance** — content in `architecture/` that misrepresents trust zones, identity, authorization, or the agent-as-client model in a way that would lead a consumer to build an insecure system.
- **Vulnerable architecture patterns** — patterns in the eight-layer model or the deployment profiles that have a known exploit path.
- **Scaffold controls that fail open** — pre-commit hooks, validators, or CI gates that produce a passing result while a real defect is present.
- **Reference-infra examples that look canonical but are insecure** — files under `infra/profiles/` that a reader might copy verbatim and ship without realizing they're examples.

## Explicitly out of scope (do not report as security issues)

These are not security issues *in this repo*; report them upstream to the relevant vendor:

- Vulnerabilities in named third-party products (Kong, Keycloak, OpenFGA, Cognito, etc.). Report those to the vendor and reference the issue in an OpenSpec proposal if it affects our profile.
- General "Cloudflare is bad" / "AWS is bad" arguments that don't identify a specific defect in our content.
- Bug reports in tools we use (pre-commit, detect-secrets, gitleaks). Report those upstream.

## What this repo will not accept under any circumstance

- A PR that adds a real secret to a `.example.*` file "just for testing." Use a `__PLACEHOLDER__`.
- A PR that suppresses a real gitleaks or detect-secrets finding via allowlist without an accompanying written justification reviewable by the security team.
- A PR that adds production tfstate, real account IDs, real tenant identifiers, or real customer data to any file in this repo.

The `pre-commit` hook chain (gitleaks + detect-secrets + the focused inline-secret check) is the first-line defense. The `.secrets.baseline` records exactly which findings have been reviewed and accepted; any new finding is treated as a fresh report until reviewed.

## Coordinated impact on consuming repos

When a scaffold-level vulnerability is confirmed:

1. The platform team opens an OpenSpec proposal (typically Tier 3) describing the issue and the fix.
2. A private heads-up goes to each affected consuming-repo lead (named in their `security-first-adoption.md`) with the planned fix and the deprecation window.
3. The fix lands in the architecture repo at a new ref.
4. Affected consumers update their `architecture_ref` and integrate within the coordinated landing window.
5. Public disclosure happens after the window closes (or sooner if the issue is already public).
