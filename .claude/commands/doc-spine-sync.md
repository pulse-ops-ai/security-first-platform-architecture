---
argument-hint: "[optional: repo path, default current dir]"
---

# Doc spine sync

Run the `doc-spine-sync` skill against the supplied repo. Canonical procedure: [`../../.agents/skills/doc-spine-sync/SKILL.md`](../../.agents/skills/doc-spine-sync/SKILL.md).

## User input

$ARGUMENTS

## Instructions

1. Resolve the repo path (default `.`).
2. Run:

   ```bash
   bash scripts/validate-doc-indexes.sh
   ```

3. Parse output for `[UNLISTED]`, `[BROKEN]`, `[ORPHAN]` findings.
4. For each `[UNLISTED]` finding, prompt the user before adding the file to the index — the right placement and grouping is a human judgement call.
5. For each `[BROKEN]` finding, either remove the broken link or restore the missing file.
6. For each `[ORPHAN]` finding, ensure the parent index links to the subdirectory's `INDEX.md`.

## Guardrails

- Indexes are NAVIGATION. Don't auto-fill an index with raw `ls` output — group files logically.
- An index that's perfectly synced can still describe a file wrongly. Structural correctness ≠ content correctness.
- Don't use this command to reorganize documentation. That's a human design task, not a mechanical sync.
