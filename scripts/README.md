# scripts/

Validation scripts called by the `.github/workflows/*.yml` healthchecks, by the `.pre-commit-config.yaml` hooks, and by the corresponding skills under [`../.agents/skills/`](../.agents/skills/).

These are intentionally simple bash scripts so they can be run locally without a toolchain.

## Scripts

| Script | Purpose |
|---|---|
| [`validate-architecture.sh`](validate-architecture.sh) | Confirm required architecture files exist; check for vendor-name leaks in `architecture/*.md` and vendor-file-as-universal leaks in `team-os/` and `standards/` |
| [`validate-doc-indexes.sh`](validate-doc-indexes.sh) | Detect drift between `INDEX.md` files and the files they should reference |
| [`validate-skills.sh`](validate-skills.sh) | Confirm every `.agents/skills/<name>/` has a compliant `SKILL.md` (frontmatter + Procedure + Output) and that `.agents/skills/INDEX.md` lists them all |
| [`sync-agent-skills.sh`](sync-agent-skills.sh) | `--check` enforces canonical ↔ vendor-shim drift rules and reports coverage; `--bootstrap <name> --vendor claude\|codex` scaffolds a new shim from a canonical skill |
| [`check-inline-secrets.sh`](check-inline-secrets.sh) | Block sensitive keys being assigned literal values in YAML / env / JSON / Terraform / shell configs. Focused complement to gitleaks and detect-secrets — catches credentials hidden behind shell-style defaults like `${VAR:-literal}` that entropy scanners miss |
| [`check-infra-secrets.sh`](check-infra-secrets.sh) | Scan `infra/` for 12-digit AWS account IDs, real ARNs with account IDs, and hard-coded region defaults outside example files. Reference infra must contain examples only |
| [`check-network-as-identity.sh`](check-network-as-identity.sh) | Heuristic source-code scanner for the "trust the network as identity" anti-pattern (client-IP-as-identity, internal-CIDR-trust, mesh-only identity, fail-open authz, hard-coded long-lived credentials). Used by the `security-control-review` skill |
| [`openspec-triage.sh`](openspec-triage.sh) | Classify a PR's diff into Tier 1/2/3 per `team-os/openspec-policy.md`; verify any required OpenSpec proposal is present and well-formed. Used by the `openspec-change-triage` skill and the `openspec-triage.yml` workflow |
| [`repo-healthcheck.sh`](repo-healthcheck.sh) | Validate any repo against `standards/repo-contract.md`. Auto-detects architecture-repo vs consumer-repo mode via the `standards/repo-contract.md` sentinel. Consumer mode enforces the Universal Floor, the `security-first-adoption.md` frontmatter (8 scalars + 8 layer children + 4 adapter children + 3 required list keys), the conditional floor, and adapter-declaration ↔ file consistency. Used by the `repo-healthcheck` skill |

## Running locally

From the repo root:

```bash
bash scripts/validate-architecture.sh
bash scripts/validate-doc-indexes.sh
bash scripts/validate-skills.sh
bash scripts/sync-agent-skills.sh --check
bash scripts/check-inline-secrets.sh        # scans all tracked config files
bash scripts/check-infra-secrets.sh         # scans infra/ for account IDs and region defaults
bash scripts/check-network-as-identity.sh . # heuristic source-tree scan
bash scripts/openspec-triage.sh origin/main # tier classification + proposal presence
bash scripts/repo-healthcheck.sh            # repo-contract validation; auto-detects mode
```

Each script exits non-zero on findings. `sync-agent-skills.sh --check` exits non-zero only on hard drift; missing optional shims/commands are warnings. `check-network-as-identity.sh` produces heuristic findings; review each one before concluding.

## `check-inline-secrets.sh` — usage notes

This script complements (does not replace) the two entropy-based scanners (`gitleaks`, `detect-secrets`):

| Scanner | What it catches |
|---|---|
| gitleaks | Well-known token formats (AWS, GitHub, Slack, Stripe, …) by signature |
| detect-secrets | High-entropy strings near "secret" / "password" / "token" keywords |
| `check-inline-secrets.sh` | **Sensitive key assigned a literal value**, including values hidden behind `${VAR:-literal}` defaults that the other two miss |

**How it decides what's a violation.** For each line where a sensitive key (from `SENSITIVE_KEYS`) is assigned a value, the script extracts the *effective* value:

- `KEY: ${ENV_VAR}` → safe (pure env ref)
- `KEY: ${ENV_VAR:-}` → safe (env ref with empty default)
- `KEY: ${ENV_VAR:-your-token-here}` → safe (default is a placeholder)
- `KEY: ${ENV_VAR:-sk_live_abc123}` → **flagged** (default is a literal)
- `KEY: changeme` → safe (placeholder word)
- `KEY: ${{ secrets.MY_TOKEN }}` → safe (GitHub Actions expression)
- `KEY: actual-real-token-value` → **flagged**

**Output discipline.** A finding prints `inline-secret: <file>:<line>: <key> assigned a literal value` — never the value itself. This keeps CI logs and PR comments safe to share.

**Where to add new sensitive keys.** Edit the `SENSITIVE_KEYS=( … )` array near the top of the script. Start narrow; add keys as you observe real leak patterns. Examples: `KAFKA_SASL_PASSWORD`, `DATABASE_URL`, `STRIPE_SECRET_KEY`. The current list is intentionally empty until the team agrees on the first set — the scaffold exists so adding keys is a one-line PR, not a "spin up a new tool" effort.

**Modes.** With no args, scans all tracked config-shaped files via `git ls-files`. With args (or when invoked by pre-commit), scans only the supplied files.

## Extending

- Keep scripts dependency-free (POSIX bash; ripgrep/awk acceptable; no Python or Node required).
- Add new checks as additional sections within an existing script when they fit; create a new script only when the scope is genuinely new.
- Update the corresponding skill's `SKILL.md` when the script's behavior changes materially.
