# scripts/

Validation scripts called by the `.github/workflows/*.yml` healthchecks and by the corresponding skills under [`../.agents/skills/`](../.agents/skills/).

These are intentionally simple bash scripts so they can be run locally without a toolchain.

## Scripts

| Script | Purpose |
|---|---|
| [`validate-architecture.sh`](validate-architecture.sh) | Confirm required architecture files exist and check for vendor-name leaks |
| [`validate-doc-indexes.sh`](validate-doc-indexes.sh) | Detect drift between `INDEX.md` files and the files they should reference |
| [`validate-skills.sh`](validate-skills.sh) | Confirm every `.agents/skills/<name>/` has a compliant `SKILL.md` (frontmatter + Procedure + Output) and that `.agents/skills/INDEX.md` lists them all |
| [`sync-agent-skills.sh`](sync-agent-skills.sh) | `--check` enforces canonical ↔ vendor-shim drift rules and reports coverage; `--bootstrap <name> --vendor claude\|codex` scaffolds a new shim from a canonical skill |

## Running locally

From the repo root:

```bash
bash scripts/validate-architecture.sh
bash scripts/validate-doc-indexes.sh
bash scripts/validate-skills.sh
bash scripts/sync-agent-skills.sh --check
```

Each script exits non-zero on findings. `sync-agent-skills.sh --check` exits non-zero only on hard drift; missing optional shims/commands are warnings.

## Extending

- Keep scripts dependency-free (POSIX bash; ripgrep/awk acceptable; no Python or Node required).
- Add new checks as additional sections within an existing script when they fit; create a new script only when the scope is genuinely new.
- Update the corresponding skill's `SKILL.md` when the script's behavior changes materially.
