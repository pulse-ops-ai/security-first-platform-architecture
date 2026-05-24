# First-consumer onboarding runbook

A step-by-step guide for bringing the first consuming repo into the security-first platform architecture. Written as a runbook so an operator can follow it linearly; written before any real consumer has onboarded so the procedure is the spec, not a retrospective.

**Audience:** the engineer or platform-team member doing the first adoption. **Expected duration:** half a day for the file changes; up to a week including review cycles and the first CI pass.

**Worked example:** the steps use `<solution-repo>` as a placeholder, with `trupryce` shown in *italics* at decision points to make it concrete. Substitute your own repo name when following along.

---

## Before you start

You should have:

- **Read the product entry point** — [`../product/INDEX.md`](../product/INDEX.md). You understand what the architecture promises, what it doesn't, and why.
- **Read the three foundational ADRs** — [`../decisions/ADR-0001`](../decisions/ADR-0001-adopt-eight-layer-control-model.md), [`ADR-0002`](../decisions/ADR-0002-agents-are-clients-not-insiders.md), [`ADR-0003`](../decisions/ADR-0003-internal-identity-envelope-as-z4-trust.md). If any of these decisions are non-starters for your repo, stop here and open an OpenSpec proposal to discuss before adopting.
- **The architecture repo cloned as a sibling** — per [`../../team-os/workspace-model.md`](../../team-os/workspace-model.md), both repos live under the same parent (`~/work/security-first-platform/` is the convention). The walkthrough assumes this layout for relative-path commands.
- **Your consuming repo exists** — at minimum, it has a `README.md` and `LICENSE`. If it doesn't exist yet, `gh repo create <org>/<solution-repo> --private` (or whatever your org's repo-bootstrap process is) before continuing.
- **You have write access** to both repos and the GitHub Enterprise org (for opening dependency records and PRs).

You do **not** need:

- Existing application code in `<solution-repo>`. Onboarding is a structural commitment, not a code change.
- A pre-existing CI pipeline in `<solution-repo>`. The walkthrough sets it up.
- Any specific AI coding agent installed. `AGENTS.md` is universal; adapter files are opt-in.

---

## Step 1 — Read the contract

Open [`../../standards/repo-contract.md`](../../standards/repo-contract.md). Read the two tables:

- **Universal Floor** — files every consumer ships (`README.md`, `AGENTS.md`, `LICENSE`, `docs/INDEX.md`, `security-first-adoption.md`, plus conditional `openspec/README.md` and `.github/workflows/`).
- **Vendor-Specific Adapters** — files required *only when* a specific tool is in use (`CLAUDE.md`, `.codex/`, `.github/copilot-instructions.md`, `.cursorrules`, etc.).

Decide which adapters apply to your team. For *trupryce*, the team uses Claude Code; so `CLAUDE.md` and `.claude/` will be in scope, others will not.

Make a note of:

- Which deployment profile you target — one of `self-hosted-vps`, `aws-managed`, `hybrid-tailnet`, or a documented custom profile.
- Which of the eight control layers your repo *implements* (owns the implementation), *consumes* (depends on another component), or marks `n/a` (doesn't apply).

These two notes drive the rest of the walkthrough.

---

## Step 2 — Copy the template

From your consuming repo's root:

```bash
# Adjust the path if your sibling clone lives elsewhere.
ARCH_REPO=../security-first-platform-architecture

# 1. Copy the consuming-repo template tree.
#
#    Note the trailing `/.` on the source — that copies the *contents*
#    of consuming-repo/ into `.` rather than nesting consuming-repo/
#    inside `.`. This form works with both GNU `cp` (Linux) and BSD
#    `cp` (macOS). Avoid `cp -rT`, which is GNU-only and fails silently
#    in unexpected ways on macOS.
cp -R "$ARCH_REPO/templates/consuming-repo/." .

# 2. Remove adapter files for tools your team does NOT use.
#    Example: trupryce uses Claude Code, not Codex.
rm -rf .codex/                    # remove if not using Codex
rm -f .github/copilot-instructions.md   # remove if not using Copilot
rm -f .cursorrules                # remove if not using Cursor

# (Keep CLAUDE.md and .claude/ if you use Claude Code.)
```

You should now have, at minimum, these new files (the template ships everything in one place):

```
AGENTS.md
CLAUDE.md                          # if using Claude
docs/INDEX.md
security-first-adoption.md
openspec/README.md
.agents/skills/INDEX.md            # if shipping local skills; otherwise rm -rf
.claude/                           # if using Claude
.github/workflows/repo-healthcheck.yml      # thin caller for the reusable
.github/workflows/docs-healthcheck.yml      # thin caller for the reusable
.github/workflows/pre-commit.yml            # thin caller for the reusable
.github/CODEOWNERS                          # placeholder consumer-shaped paths
.pre-commit-config.yaml                     # consumer-portable hook chain
.secrets.baseline                           # empty starting baseline
.gitleaks.toml                              # narrow allowlist for .secrets.baseline
```

The `.github/workflows/*.yml` files contain `__ARCHITECTURE_REF__` placeholders — step 3 below replaces them with your pinned ref.

---

## Step 3 — Pin the architecture-repo ref

Open `security-first-adoption.md` in your editor. In the YAML frontmatter, set:

```yaml
architecture_repo:    https://github.com/pulse-ops-ai/security-first-platform-architecture
architecture_ref:     <choose: SHA, tag, or branch>
architecture_ref_kind: <sha | tag | branch>
adoption_date:        <today, ISO 8601>
```

**Recommended pin:** the latest tag (`git -C "$ARCH_REPO" describe --tags --abbrev=0` from your local sibling clone, or browse the [Releases page](https://github.com/pulse-ops-ai/security-first-platform-architecture/releases)). Tag pins are the production default per [`../../team-os/cross-repo-governance.md`](../../team-os/cross-repo-governance.md) §Pinning.

For *trupryce* doing first-ever onboarding: pin the most recent merged-to-main SHA (since tags will be cut in lockstep with consumer milestones — see "Open your dependency record" below).

**Now propagate that ref into the workflow files.** The template ships three workflows with `__ARCHITECTURE_REF__` placeholders that must be replaced with your pinned ref (both in the `uses: ...@<ref>` line and the `with: architecture_ref:` input where present):

```bash
REF="<your pinned ref>"   # same value you put in architecture_ref:
sed -i.bak "s|__ARCHITECTURE_REF__|$REF|g" .github/workflows/repo-healthcheck.yml \
                                            .github/workflows/docs-healthcheck.yml \
                                            .github/workflows/pre-commit.yml
rm .github/workflows/*.bak
```

(On macOS `sed -i.bak` works without GNU `sed`; the `.bak` files are removed after. Adjust if your team has a preferred substitution tool.)

When you bump `architecture_ref` later, redo this `sed` against the new ref in the same PR — the workflow `@ref` MUST match the adoption record's `architecture_ref`.

---

## Step 4 — Declare your deployment profile

In `security-first-adoption.md` frontmatter:

```yaml
profile:              <one of: self-hosted-vps | aws-managed | hybrid-tailnet | <custom>>
```

If you're on a custom profile, also link to your profile doc (under your own `docs/` tree or under `infra/profiles/<custom>/` if you're contributing it upstream). A custom profile that isn't documented anywhere will fail the `architecture-review` skill at first PR.

For *trupryce*: `self-hosted-vps` (current state) → migration to `hybrid-tailnet` in a future Tier 2 OpenSpec.

---

## Step 5 — Map your eight control layers

This is the longest field but it's the heart of the adoption record. Fill in `adopted_control_layers:` with one of `implemented` | `consumed` | `n/a` for each of L1–L8.

Reference: [`../../architecture/control-layers.md`](../../architecture/control-layers.md) for what each layer is.

| Layer | Decision rule |
|---|---|
| `l1_network_reachability` | `implemented` if you own the tunnel / mesh / subnet config. `consumed` if a parent platform handles network admission for you. |
| `l2_edge_gateway` | `implemented` if you run Kong / Traefik / ALB / API Gateway. `consumed` if you sit behind a shared edge. |
| `l3_identity` | `implemented` if you run your own IdP (Keycloak, Cognito, …). `consumed` if you federate from a parent IdP. |
| `l4_authorization` | `implemented` if you run OpenFGA / Verified Permissions / OPA. `consumed` if you delegate authz to a parent service. |
| `l5_operational_guardrails` | `implemented` if you own rate limits, quotas, feature flags. `consumed` if the edge or a sidecar does this for you. |
| `l6_orchestrator_bff` | `implemented` if you ship a BFF / orchestrator. `n/a` if your repo is a leaf service. |
| `l7_service_enforcement` | `implemented` if your repo contains services with per-service authz + tenant-scoped data access. `n/a` if your repo is purely infrastructure or tooling. |
| `l8_semantic_agent` | `implemented` if you run an agent runtime in this repo. `n/a` if the repo is non-agentic. |

For *trupryce* (a property-data SaaS): L1 implemented (own VPS), L2 implemented (Kong), L3 implemented (Keycloak), L4 implemented (OpenFGA), L5 implemented (Kong + Redis), L6 implemented (Node BFF), L7 implemented (multiple services), L8 implemented (semantic search agent for listings).

---

## Step 6 — Declare adapters in use

In `security-first-adoption.md` frontmatter:

```yaml
agent_adapters_in_use:
  claude_code:        true | false
  codex:              true | false
  github_copilot:     true | false
  cursor:             true | false
  other: []           # list any others; describe in 1-line each
```

This drives `repo-healthcheck` — it only validates adapter files for tools you've declared in use. Setting `claude_code: false` and shipping a `CLAUDE.md` is a `repo-healthcheck` finding (likely unintentional leftover from the template).

For *trupryce*: `claude_code: true`, others `false`.

---

## Step 7 — Owners and review cadence

In `security-first-adoption.md` frontmatter:

```yaml
owner:                <GitHub handle of a real human, not a team>
owning_team:          <GitHub Enterprise team slug>
review_cadence:       <monthly | quarterly | per-release | on-architecture-change>
last_review_date:     # blank on first adoption
next_review_date:     # ISO 8601, per review_cadence
```

Pick a cadence that matches how often your team makes architecture-affecting decisions. For a fast-moving repo: `monthly`. For a stable repo: `quarterly`. For a repo gated by formal releases: `per-release`. The `on-architecture-change` option means "review only when the architecture repo's ref moves" — fine for stable consumers.

For *trupryce*: `quarterly`, owner `@<lead>`, owning team `@trupryce-platform`.

---

## Step 8 — Open your dependency record

Switch to the architecture repo. From `~/work/security-first-platform/security-first-platform-architecture`:

```bash
git checkout -b chore/dependency-record-<solution-repo>

# Use the template.
TODAY=$(date -u +%Y-%m-%d)
DEP_PATH=portfolio/dependencies/${TODAY}-<solution-repo>-depends-on-architecture-onboarding.md
cp templates/dependency-record/dependency-template.md "$DEP_PATH"
$EDITOR "$DEP_PATH"
```

Fill in every required field per the template (see [`../../templates/dependency-record/dependency-template.md`](../../templates/dependency-record/dependency-template.md)):

- `dependency_id` — e.g., `DEP-2026-MM-DD-001`
- `title` — *"<solution-repo> initial adoption of security-first platform architecture"*
- `upstream_repo` — `security-first-platform-architecture`
- `upstream_ref`, `upstream_ref_kind` — match what you put in `security-first-adoption.md`
- `upstream_artifact` — `standards/repo-contract.md` (the contract being adopted)
- `downstream_repo` — `<solution-repo>`
- `downstream_artifact` — `security-first-adoption.md`
- `dependency_type` — `contract`
- `impact_tier` — `2` (initial adoption is a Tier 2 commitment for the consumer)
- `status` — `in_progress`
- `blocking_direction` — `blocks-downstream` (the consumer is following the contract; nothing in the architecture repo is blocked by this)
- `required_by`, `deprecation_window`, `coordinated_landing_order`, `owner`, `opened_date`, `resolved_date` — populate per template guidance
- `related_openspec_proposal` — `n/a` for first adoption (no architecture-side proposal triggered this; the consumer is the initiator)

Commit and open a PR against the architecture repo. This PR will move to `resolved` after step 11's PR (in your own repo) merges.

---

## Step 9 — Configure your CI

The template already shipped three workflows in `.github/workflows/` (step 2) and you replaced their `__ARCHITECTURE_REF__` placeholders with your pinned ref (step 3). Those workflows are **thin callers** for the reusable workflows defined in the architecture repo — there is no script-copying or workflow-authoring left for you to do.

Confirm by listing your workflow files:

```bash
ls .github/workflows/
# expected:
# repo-healthcheck.yml
# docs-healthcheck.yml
# pre-commit.yml
```

Each one's `uses:` line should reference `pulse-ops-ai/security-first-platform-architecture/.github/workflows/<name>.yml@<your-pinned-ref>` (no `__ARCHITECTURE_REF__` placeholders remaining):

```bash
grep -H "uses:" .github/workflows/*.yml
```

Those three workflows ARE the universal-floor CI baseline defined in [`../../standards/ci-cd-standard.md`](../../standards/ci-cd-standard.md) §Required workflows in every repo. You don't need to add anything else to satisfy the floor.

**Optional additions** (conditional on what your repo exposes):

- `skills-healthcheck.yml` — required by the CI/CD standard **only if** your repo has `.agents/skills/`. This workflow is **not reusable yet** (it calls `scripts/validate-skills.sh` and `scripts/sync-agent-skills.sh` directly in the architecture repo's own checkout). Until it gains a `workflow_call:` trigger in a follow-up PR, your options if you adopt local skills are:
  - Wait for the reusable version (preferred — no per-consumer maintenance), OR
  - Vendor both the workflow AND the two scripts into your repo and accept that you'll need to keep them in sync with `architecture_ref` bumps yourself.
- `openspec-triage.yml` and `codeowners-check.yml` — required only if your team adopts the OpenSpec policy or required-path ownership enforcement. **Same limitation**: not reusable yet (call `scripts/openspec-triage.sh` and architecture-repo-specific path enforcement, respectively). Vendor scripts + workflow if you must adopt now; otherwise wait for the reusable versions.
- For action pinning hygiene, the `github-enterprise-ci-review` skill flags any unpinned `uses:` lines in your workflows.

`architecture-healthcheck.yml` is architecture-repo-specific (it validates the architecture repo's own `architecture/` tree). Consumers do NOT need it.

The template's `.pre-commit-config.yaml`, `.secrets.baseline`, and `.gitleaks.toml` (also from step 2) cover local-dev hook hygiene. They are deliberately a **consumer-portable subset** of what the architecture repo runs on itself — no architecture-specific scripts; just file hygiene, secrets, and shellcheck.

---

## Step 10 — Validate

Run the consumer-facing healthchecks **inside your consuming repo's directory**:

```bash
# Pre-commit (if you installed the hooks):
pre-commit run --all-files

# Repo healthcheck — validates the Universal Floor, the
# security-first-adoption.md frontmatter, the conditional floor
# (openspec/, .github/workflows/, .agents/skills/ when present), and
# vendor-adapter consistency against the agent_adapters_in_use:
# declarations.
bash scripts/repo-healthcheck.sh
```

If your consuming repo doesn't yet have a local copy of `scripts/repo-healthcheck.sh`, run it directly from the architecture repo:

```bash
bash ../security-first-platform-architecture/scripts/repo-healthcheck.sh .
```

The script auto-detects whether it's running in the architecture repo or a consuming repo (via the presence of `standards/repo-contract.md` as the sentinel) and runs the appropriate set of checks. In your consumer it will run the **consumer-mode** checks:

- All Universal Floor files / directories present.
- `security-first-adoption.md` frontmatter has every required field populated (8 scalars, 8 `adopted_control_layers` children, 4 `agent_adapters_in_use` children, 3 required list keys).
- The conditional floor (`openspec/README.md` if `openspec/` exists, `.agents/skills/INDEX.md` if `.agents/skills/` exists, `.github/workflows/` if owned).
- Vendor adapters consistent with declarations: each `agent_adapters_in_use.<x>: true` has its files; each `: false` does NOT have its files; any present adapter routes to `AGENTS.md`.
- `AGENTS.md` is non-empty and references the architecture + team-os entrypoints.

Findings are prefixed `[OK]` / `[INFO]` / `[WARN]` / `[ERROR]`. Only `[ERROR]` fails the check (script exits 1). The full set of categories and how to interpret each is documented in [`.agents/skills/repo-healthcheck/SKILL.md`](../../.agents/skills/repo-healthcheck/SKILL.md) — "Interpret findings."

Fix every `[ERROR]` before opening the first PR. The most common errors and their fixes:

| Error | Fix |
|---|---|
| `frontmatter field '<key>' is empty (or comment-only)` | Open `security-first-adoption.md`, replace the template's `key: # comment` with `key: <real-value>`. |
| `Adapter mismatch: <x> is 'false' but <file> is present` | Either set `<x>: true` if you actually use it, or remove the file. Do NOT keep both. |
| `MISSING <adapter-file> (<x>: true)` | Either add the adapter file, or change the declaration to `false` if you don't use it. |
| `<adapter-file> does not reference AGENTS.md` | The adapter file should be a short router pointing at `AGENTS.md`, not a duplicate contract. Edit it to include "See AGENTS.md" or equivalent. |

**Note:** `scripts/validate-architecture.sh` is the architecture repo's *own* vendor-neutrality scanner — it does not run against consuming repos. The consumer-facing validator is `repo-healthcheck.sh`.

---

## Step 11 — Open your first PR

In `<solution-repo>`, open a PR that adds the new files from step 2 + your populated `security-first-adoption.md`. PR title:

```
feat(adopt): bring <solution-repo> into the security-first platform architecture
```

PR body should include:

- A link to your dependency record in the architecture repo (from step 8)
- The architecture-repo ref you pinned
- The profile you adopted
- Any deviations declared (with compensating controls)
- A test plan that includes `pre-commit run --all-files` and `repo-healthcheck` invocations

Reviewers: your consuming-repo lead, plus the architecture repo's platform team for cross-repo awareness.

Once this PR merges:

- Switch back to the architecture repo's dependency-record PR (from step 8).
- Update `status` to `resolved`, fill in `resolved_date`, and merge that PR.
- Update `docs/product/INDEX.md` in the architecture repo's "Current adoption state" table with your repo's row (a small follow-up PR by the platform team).

---

## What happens after onboarding

| Trigger | What you do |
|---|---|
| Architecture repo ships a Tier 2 change | The platform team opens a dependency record against your repo. You acknowledge by adding the change to `pending_openspec_changes:` in your `security-first-adoption.md`. Integrate by your `required_by:` date. |
| Architecture repo ships a Tier 3 change | Same as Tier 2 but you also acknowledge the new ADR. Some Tier 3 changes require code work in your repo; the dependency record tells you what. |
| `review_cadence` interval elapses | Open a small PR in your repo: update `last_review_date`, set `next_review_date`, add a row to the Review record table in `security-first-adoption.md`. Confirm `pending_openspec_changes:` is current. |
| You want to move to a new architecture-repo ref | Open an OpenSpec proposal *in your repo* (it's a Tier 2 change for your consumer). Confirm `pending_openspec_changes:` is empty for the new ref before merging. |
| You discover a deviation that needs a compensating control | Add it to `deviations:` with the required fields. If the deviation will close in a known timeframe, set `scheduled_remediation`. Otherwise, open an OpenSpec proposal in the architecture repo to discuss making the deviation a first-class supported pattern. |

---

## Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `repo-healthcheck` says `[MALFORMED] CLAUDE.md` | You left the template's `<REPO_NAME>` placeholder unfilled. | Replace `<REPO_NAME>` in `CLAUDE.md` with your repo name. |
| `repo-healthcheck` says `[UNLISTED] security-first-adoption.md` | The file is at the wrong path (not at repo root). | Move it to the root. The contract requires it at the root, not under `docs/`. |
| CI fails on `architecture-healthcheck` with "no INDEX.md" | You removed `docs/INDEX.md` thinking it was a stub. | Restore it — it's part of the Universal Floor. |
| `openspec-triage` fails on your first PR | Your repo doesn't have `openspec/` yet but the PR touches a Tier 2 path. | Either add `openspec/README.md` and a thin proposal, OR move your Tier 2 changes to a separate PR after the initial adoption lands. |
| Dependabot or auto-merge tools fail your `openspec-triage` check | Trusted bots need the explicit exemption from the architecture repo's `scripts/openspec-triage.sh` (`GITHUB_ACTOR == 'dependabot[bot]'`). | Copy the exemption logic into your repo's version of the script. |
| Pinning to a branch instead of a tag/SHA | Discouraged outside integration testing. | Move to a tag pin in your next adoption review. |
| Adapter files for tools you don't use are left in the template | Step 2's cleanup was incomplete. | Re-run the `rm` commands from step 2 and update `agent_adapters_in_use:`. |

---

## Getting help

- **Architecture or contract questions** → open an issue in the architecture repo, tagged with your `<solution-repo>` and the layer/contract you're asking about. For Tier 2/3 questions, open an OpenSpec proposal.
- **Onboarding-procedure questions** → ping the platform team in the org's main chat. If a question recurs across consumers, file an issue to update this runbook.
- **Security questions** → see [`../../SECURITY.md`](../../SECURITY.md). Do not open public issues for security topics.
- **"Is X a deviation?" questions** → if in doubt, declare it. The cost of a documented deviation with a compensating control is small; the cost of an undocumented deviation discovered during audit is large.

---

## What to expect in the next 90 days after onboarding

- **Week 1–2**: shake out any CI / workflow issues the runbook didn't anticipate. File issues against this runbook for any gotcha you hit.
- **Week 3–4**: first architecture-repo dependency record probably lands against your repo. Use it to validate the cross-repo coordination machinery end-to-end.
- **Month 2**: your first regular review (if `monthly` cadence). Confirm the `pending_openspec_changes:` field works as designed.
- **Month 3**: your repo should be listed in the architecture repo's `docs/product/INDEX.md` "Current adoption state" table. If it isn't, ping the platform team.

If any of the above slip, that's signal — either the runbook needs updating or the architecture repo's adoption contract needs tightening. Either way, surface it as an OpenSpec proposal.
