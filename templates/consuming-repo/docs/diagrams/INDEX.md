# docs/diagrams/ — Index

> **Template.** This directory is the home for your repo's diagrams. Replace this index's example row with your real diagrams as you add them, and delete this note.

Diagrams that document **this repo's** deployment, topology, and security boundaries. The visual vocabulary, archetype catalog, contrast rules, and source-of-truth-citation requirements are defined upstream in the architecture repo's `standards/diagramming-conventions.md` — read it in the sibling clone at `../security-first-platform-architecture/` (at the `architecture_ref` pinned in [`../../security-first-adoption.md`](../../security-first-adoption.md)). This directory is what that standard looks like for your repo.

## How to add a diagram

1. **Start from a template.** Copy the archetype whose *question* matches what you need from the architecture repo's `architecture/diagrams/templates/` (pick-by-question table in its `templates/README.md`):
   - trust-zone / layer architecture · deployment topology · C4 System Context · C4 Container (drawio)
   - trust-zone sequence · C4 Dynamic · decision tree (Mermaid)
2. **Fill in the `<placeholders>`** with your services, zones, and flows. Profile-specific diagrams that name your real vendors belong **here**, in your repo — not in the architecture repo (which stays vendor-neutral).
3. **Export the paired SVG** (drawio only) with the workspace flags:
   ```bash
   drawio -x -f svg -e --embed-svg-fonts false -b 10 \
     -o docs/diagrams/<name>.svg docs/diagrams/<name>.drawio
   ```
4. **Add the footer** citing your source-of-truth doc(s) + `Last reviewed: YYYY-MM-DD` and add a row to the table below.

## Contents

| Diagram | Archetype | Source of truth | Last reviewed | Next review |
|---|---|---|---|---|
| _(example — replace)_ `<name>.drawio` + `.svg` | _(e.g. Deployment topology)_ | _(cite the doc(s) / ADR(s) this diagram realises)_ | `YYYY-MM-DD` | `YYYY-MM-DD` |

## Conventions

- Every `.drawio` MUST ship a paired rendered `.svg` (so readers without drawio can view it in GitHub).
- Every diagram MUST cite its source-of-truth doc(s) in a footer text element with a `Last reviewed:` date.
- One archetype per diagram (no mixing trust-zone and C4 vocabulary in one image).
- New diagrams are added with one row per diagram above. Re-review on the `Next review` cadence (90 days).

## Enforcement

The architecture repo's `validate-diagrams.sh` runs in your CI through the `docs-healthcheck` reusable workflow (from `architecture_ref` ≥ `v0.3.0`): a **missing paired SVG or missing footer fails CI**; a stale footer or low-contrast text is reported as a warning. To run it locally before pushing:

```bash
bash ../security-first-platform-architecture/scripts/validate-diagrams.sh .
```
