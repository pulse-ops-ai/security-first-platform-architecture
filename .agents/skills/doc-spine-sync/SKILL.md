---
name: doc-spine-sync
description: Detect drift between INDEX.md files and the folders they should reference. Use after adding, renaming, or removing markdown files, before merging a multi-doc PR, or routinely in CI as part of docs-healthcheck.
---

# Doc spine sync

Confirm that every folder with an `INDEX.md` references its sibling markdown files, and that every link in those indexes resolves to a file that exists. Indexes are the navigation spine; drift makes the repo agent-hostile.

## Inputs

- Path to a repository (default: current working directory).

## Procedure

1. For each directory containing an `INDEX.md`:
   1. List sibling `*.md` files at depth 1, excluding `INDEX.md` itself.
   2. Confirm each sibling is referenced from the index by a relative link or by name.
   3. Confirm each link in the index resolves to a file that exists.
2. For each subdirectory that has its own index, confirm the parent index links to it.
3. Record findings:
   - `UNLISTED <file>` — file exists in folder but is not in the index.
   - `BROKEN <link>` — link in the index points to a missing file.
   - `ORPHAN <subdir>` — a subdirectory has an index but the parent index doesn't link to it.

## Output

Return findings grouped by index file:

```
docs/INDEX.md
  [BROKEN] product/old-vision.md

.agents/skills/INDEX.md
  [UNLISTED] new-skill/SKILL.md
```

Exit `PASS` if clean, `FAIL` if any findings.

## Guardrails

- This skill checks structure, not correctness. An index can be perfectly synced and still describe a file wrongly.
- Do not auto-fix by adding files to the index without human review — the right placement and grouping matters.
- Avoid running this skill as a substitute for re-organizing documentation; that is a human design task.

## See also

- [`../../../scripts/validate-doc-indexes.sh`](../../../scripts/validate-doc-indexes.sh)
- [`../../../standards/documentation-standard.md`](../../../standards/documentation-standard.md)
