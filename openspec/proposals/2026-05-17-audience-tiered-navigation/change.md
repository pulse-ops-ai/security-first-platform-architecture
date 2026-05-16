# OpenSpec Change: Audience-Tiered Navigation

Companion to [`proposal.md`](proposal.md).

## Files modified

### Top-level navigation

- **`README.md`** — rewritten as a thin audience-routing landing page.
  - Kept: title, motto, one-paragraph description, license link.
  - Replaced: the mixed-audience "How to navigate this repo" table is now a 6-row audience-tiered entry-point table.
  - Removed: duplicated sections that belong to specific audience surfaces:
    - "Core thesis" → moves to `architecture/INDEX.md` and `docs/product/INDEX.md`
    - "Workspace model" → already in `team-os/workspace-model.md`; README now points there via the routing table
    - "Agents" → already in `AGENTS.md`; README now points there
    - "Governance" → already in `team-os/openspec-policy.md`; README now points there
  - Result: ~92 lines → ~40 lines. No information loss; readers now go to the authoritative surface for what they need.

- **`AGENTS.md`** — "Where to find things" table gets a new row pointing at `docs/decisions/INDEX.md`. No other changes.

- **`CLAUDE.md`** — "Read first" list adds `docs/decisions/INDEX.md`.

### Architecture surface

- **`architecture/INDEX.md`** — gains a `## Related decisions` section linking to ADR-0001, ADR-0002, ADR-0003. Other sections unchanged.

- **`architecture/control-layers.md`** — gains a `> See ADR-0001 for the trade-off record.` callout right after the title.

- **`architecture/agent-as-client-model.md`** — gains a `> See ADR-0002 for the trade-off record.` callout right after the title.

- **`architecture/internal-identity-envelope.md`** — gains a `> See ADR-0003 for the trade-off record.` callout right after the title.

### Product surface

- **`docs/product/INDEX.md`** — was a stub with the line "_None yet._ Drafts will land here as the kit matures." Now populated with real content:
  - What this repo promises (stable architecture model, vendor neutrality, adoption contract, OpenSpec governance)
  - What it doesn't promise (no runtime, no SLAs, no managed offering)
  - Who owns it (platform team; consuming-repo leads for their adoption records)
  - Foundational decisions (links to the three ADRs)
  - How consumers adopt (links to `standards/repo-contract.md` and `templates/consuming-repo/`)
  - Current adoption state (none yet; placeholder for the first consumer)
  - Current phase (scaffold; first consumer onboarding is the next visible milestone)

## Files NOT moved

The proposal explicitly does not rename or relocate any existing file. Specifically:

- `architecture/` stays at the root (not moved under `docs/`).
- `SECURITY.md` stays at the root (it's a GitHub-recognized convention).
- All architecture, team-os, standards, templates, infra paths unchanged.

This avoids breaking every cross-reference in the existing docs and avoids invalidating any consumer's planned link.

## Contract changes

None. This PR adds and restructures *navigation*; no contract surface (envelope schema, repo contract, OpenSpec policy, eight-layer model, …) is modified.

## Cross-repo migration steps

None — `completion_state: architecture-complete`. Existing references to `README.md` continue to work (the file is restructured in place, not deleted or moved).

## Rollback

Each change is independently revertible:

- `README.md` — git revert to restore the previous mixed-audience surface.
- `docs/product/INDEX.md` — revert to restore the stub state.
- Architecture cross-links — single-line removals.
- `AGENTS.md` / `CLAUDE.md` table additions — single-line removals.

No rollback is irreversible.

## Verification

- `validate-architecture.sh` — passes (no vendor-name leaks introduced; the `architecture/*.md` files don't gain vendor mentions).
- `validate-doc-indexes.sh` — passes (the new `## Related decisions` section in `architecture/INDEX.md` references `../docs/decisions/ADR-*.md` paths that exist).
- `validate-skills.sh`, `sync-agent-skills.sh --check` — unaffected.
- `check-infra-secrets.sh`, `check-network-as-identity.sh` — unaffected.
- `openspec-triage.sh origin/main` — classifies as Tier 2 because `AGENTS.md`, `architecture/*.md`, and `architecture/INDEX.md` are touched; this proposal directory is present.
- `pre-commit run --all-files` — 18 hooks pass.
- Manual: each of the six audience entry points in the new `README.md` table resolves to an existing file with real content.
