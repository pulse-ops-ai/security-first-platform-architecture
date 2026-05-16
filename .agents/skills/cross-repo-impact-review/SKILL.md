---
name: cross-repo-impact-review
description: Identify which consuming repos a change affects, and confirm dependency records exist. Use when a PR touches AGENTS.md, a standard, a template, an architecture document, OpenSpec/governance docs, or when opening a portfolio epic.
---

# Cross-repo impact review

For changes in the architecture repo, map which solution repos must respond, and confirm a dependency record exists for each affected consumer before merge.

## Inputs

- The PR or diff under review.
- The architecture repo path (default: current working directory).
- The sibling-repo parent directory (default: `..` — i.e., this repo's parent, which is `~/work/security-first-platform/` per `team-os/workspace-model.md`).

## Sibling repos to scan

Per [`../../../team-os/workspace-model.md`](../../../team-os/workspace-model.md), the workspace contains these solution repos as siblings. Scan each that is present locally; skip any that aren't checked out.

| Sibling repo | Where it lives |
|---|---|
| `trupryce` | `../trupryce/` |
| `findevil` | `../findevil/` |
| `levelup-platform` | `../levelup-platform/` |
| `splunk-agentic-ops` | `../splunk-agentic-ops/` |

Also include any other sibling directory at `../*/` that contains an `AGENTS.md` and a `security-first-adoption.md` — those are by definition consuming repos.

## Procedure

1. **Enumerate touched artifacts.** Get the list of changed files:

   ```bash
   git diff --name-only origin/main...HEAD
   ```

   Bucket each file by impact category:
   - `architecture/internal-identity-envelope.md` → envelope schema
   - `architecture/control-layers.md` / `architecture/principles.md` → core model
   - `architecture/agent-as-client-model.md` → agent-as-client rule
   - `architecture/profiles/*.md` → profile contract
   - `standards/*.md` → standard
   - `templates/**` → template
   - `AGENTS.md` → universal contract
   - other → assess individually

   Files outside these buckets are unlikely to have cross-repo impact.

2. **Discover present siblings.**

   ```bash
   for sibling in trupryce findevil levelup-platform splunk-agentic-ops; do
     if [[ -d "../$sibling" && -f "../$sibling/AGENTS.md" ]]; then
       echo "found: $sibling"
     fi
   done
   ```

   Also scan `../*/AGENTS.md` for siblings not on the named list.

3. **Search each sibling for references to touched artifacts.** For every artifact in step 1's buckets, run:

   ```bash
   # Replace <artifact-basename> with the touched file's basename without extension.
   rg -n --hidden "<artifact-basename>" "../<sibling>/" 2>/dev/null
   ```

   Example: a change to `architecture/internal-identity-envelope.md` should be checked with:

   ```bash
   rg -n --hidden "internal-identity-envelope|internal identity envelope|envelope.*claim" ../trupryce/
   ```

   Also check the sibling's `security-first-adoption.md` for matching `pending_openspec_changes` or `cross_repo_dependencies` entries:

   ```bash
   for sibling in $(ls -d ../*/ 2>/dev/null); do
     [[ -f "$sibling/security-first-adoption.md" ]] && \
       echo "== $sibling/security-first-adoption.md ==" && \
       grep -nE 'pending_openspec_changes|cross_repo_dependencies' "$sibling/security-first-adoption.md"
   done
   ```

4. **Check for matching dependency records.** For each sibling that references a touched artifact:

   ```bash
   ls portfolio/dependencies/ | grep -E "$(basename <sibling>)"
   ```

   If no record exists AND the change is Tier 2 or Tier 3, this is a `BLOCK`. The proposal MUST link one dependency record per affected consumer (see [`../../../team-os/cross-repo-governance.md`](../../../team-os/cross-repo-governance.md) §Dependency-record linkage).

5. **Record findings.** For each affected sibling, capture:
   - Sibling name
   - Touched architecture-repo artifact
   - Where the artifact is referenced in the sibling (file + line)
   - Matching dependency record path, or `MISSING`
   - Sibling's current `architecture_ref` from its `security-first-adoption.md`

## Output

Return a structured report:

```
Touched architecture-repo artifacts:
  - architecture/internal-identity-envelope.md
  - standards/security-first-architecture-standard.md

Siblings present locally: trupryce, findevil
Siblings not checked out: levelup-platform, splunk-agentic-ops

Affected consumers:
  - trupryce
      references found:
        bff/src/envelope.ts:14  "internal-identity-envelope"
        docs/operations/envelope-ops.md:7
      current architecture_ref:  v0.3.2  (from security-first-adoption.md)
      dependency record:         [MISSING]  ← BLOCK if tier 2/3
  - findevil
      references found:  (none)
      current architecture_ref:  abc1234
      dependency record:         portfolio/dependencies/2026-05-10-findevil-depends-on-architecture-envelope.md  [OK]

Recommendation: open a dependency record for trupryce before merging this Tier 2/3 change.
```

## Guardrails

- Do not silently merge a Tier 2/3 change without dependency records for affected consumers — that hides coordination cost.
- Do not assume "no record means no impact"; verify by scanning sibling repos when they are cloned locally.
- Do not edit other repos as part of this skill — only report.
- If a sibling is not checked out locally, flag it as "not verified" in the report rather than assuming no impact.

## See also

- [`../../../team-os/cross-repo-governance.md`](../../../team-os/cross-repo-governance.md)
- [`../../../team-os/workspace-model.md`](../../../team-os/workspace-model.md)
- [`../../../portfolio/`](../../../portfolio/)
- [`../../../templates/dependency-record/dependency-template.md`](../../../templates/dependency-record/dependency-template.md)
