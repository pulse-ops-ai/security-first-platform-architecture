# Doc spine sync

Run the `doc-spine-sync` skill against the **current repo**. Canonical procedure: [`../../.agents/skills/doc-spine-sync/SKILL.md`](../../.agents/skills/doc-spine-sync/SKILL.md).

## Instructions

1. This command scans the current repo. `validate-doc-indexes.sh` resolves its own ROOT relative to the script location, so the check always covers the repo containing the script. To audit a different repo, `cd` to that repo's root before invoking.
2. Run:

   ```bash
   bash scripts/validate-doc-indexes.sh
   ```

3. Parse the output for these markers:
   - `[OK]` — sibling `.md` file referenced by `INDEX.md` (no action).
   - `[UNLISTED]` — sibling `.md` exists in folder but is not in the index.
   - `[BROKEN]` — relative link in `INDEX.md` points to a missing file.
   - `[ORPHAN]` — a subdirectory has its own `INDEX.md` but the parent doesn't link to it.
4. For each `[UNLISTED]` finding, prompt the user before adding the file to the index — the right placement and grouping is a human judgement call.
5. For each `[BROKEN]` finding, either fix the link target or restore the missing file. Do not silently remove the link.
6. For each `[ORPHAN]` finding, add a link from the parent index to the subdirectory's `INDEX.md`.

## Guardrails

- Indexes are NAVIGATION. Don't auto-fill an index with raw `ls` output — group files logically.
- An index that's perfectly synced can still describe a file wrongly. Structural correctness ≠ content correctness.
- Don't use this command to reorganize documentation. That's a human design task, not a mechanical sync.
