---
name: drawio
description: Always use when user asks to create, generate, draw, or design a diagram, flowchart, architecture diagram, ER diagram, sequence diagram, class diagram, network diagram, mockup, wireframe, or UI sketch, or mentions draw.io, drawio, drawoi, .drawio files, or diagram export to PNG/SVG/PDF.
---

# Drawio diagram skill

Generate drawio diagrams as native `.drawio` files. Optionally export to PNG, SVG, or PDF with the diagram XML embedded (so the exported file remains editable in drawio).

When the diagram is an **architecture, trust-zone, or deployment-topology** diagram for a repo in this workspace, follow the visual vocabulary in [`../../../standards/diagramming-conventions.md`](../../../standards/diagramming-conventions.md) — fixed zone colours, layer-ribbon strokes, agent-as-client lane, and deviation marker. The standard is the **what**; this skill is the **how**.

## Inputs

- Diagram intent (what to draw — flowchart, ER, sequence, architecture topology, etc.).
- Optional output format: `png`, `svg`, `pdf`, or none (just `.drawio`).
- Optional target directory (defaults to current working directory; in a consuming repo, prefer `docs/diagrams/`).

## Procedure

1. **Generate drawio XML** in mxGraphModel format for the requested diagram.
2. **Write the XML** to a `.drawio` file using the Write tool. In a consuming repo, place it under `docs/diagrams/`; in the architecture repo, under `architecture/diagrams/`. Match the naming convention from the standards doc.
3. **Post-process edge routing** (optional): If `npx @drawio/postprocess` is available, run it on the `.drawio` file to optimize edge routing (simplify waypoints, fix edge-vertex collisions, straighten approach angles). Skip silently if not available — do not install it or ask the user about it.
4. **If the user requested an export format** (`png`, `svg`, `pdf`), locate the drawio CLI (see [§Locating the CLI](#locating-the-cli)), export with `--embed-diagram`, then **keep both the `.drawio` source and the rendered file** when the diagram lives under `docs/diagrams/` or `architecture/diagrams/` — the standard requires both, so readers without drawio can view the diagram in GitHub. For one-off scratch diagrams outside those directories, you may delete the source after export.
5. **Open the result** — the exported file if exported, or the `.drawio` file otherwise. If the open command fails, print the file path so the user can open it manually.
6. **Add a footer** citing the source-of-truth doc, per the standard: `Source: <path> · Last reviewed: YYYY-MM-DD by <handle>`. If the diagram is architectural, this is non-negotiable — add it as a text element near the bottom edge.
7. **Update the relevant `INDEX.md`** (`docs/diagrams/INDEX.md` or `architecture/diagrams/INDEX.md`) with the new entry, including `last_reviewed:` and `next_review:` (90 days out).

## Output

- A `.drawio` file (native mxGraphModel XML) at the target path.
- Optionally a rendered `.png`, `.svg`, or `.pdf` alongside (the export contains embedded XML and remains editable in drawio).
- An updated `INDEX.md` entry where applicable.
- The file path of the result, printed to stdout for visibility.

## Choosing the output format

Check the user's request for a format preference. Examples:

- `/drawio create a flowchart` → `flowchart.drawio`
- `/drawio png flowchart for login` → `login-flow.drawio.png`
- `/drawio svg: ER diagram` → `er-diagram.drawio.svg`
- `/drawio pdf architecture overview` → `architecture-overview.drawio.pdf`

If no format is mentioned, write the `.drawio` file and open it in drawio. The user can always ask to export later.

### Supported export formats

| Format | Embed XML | Notes |
|--------|-----------|-------|
| `png` | Yes (`-e`) | Viewable everywhere, editable in drawio |
| `svg` | Yes (`-e`) | Scalable, editable in drawio (preferred for repo-committed renderings) |
| `pdf` | Yes (`-e`) | Printable, editable in drawio |
| `jpg` | No | Lossy, no embedded XML support |

For diagrams committed to `docs/diagrams/` or `architecture/diagrams/`, **prefer `svg`** — it scales cleanly in any GitHub render and the embedded XML keeps the file editable.

## drawio CLI

The drawio desktop app includes a command-line interface for exporting.

### Locating the CLI

First detect the environment, then locate the CLI accordingly.

#### WSL2 (Windows Subsystem for Linux)

WSL2 is detected when `/proc/version` contains `microsoft` or `WSL`:

```bash
grep -qi microsoft /proc/version 2>/dev/null && echo "WSL2"
```

On WSL2, use the Windows drawio Desktop executable via `/mnt/c/...`:

```bash
DRAWIO_CMD=`/mnt/c/Program Files/draw.io/draw.io.exe`
```

The backtick quoting is required to handle the space in `Program Files` in bash.

If drawio is installed in a non-default location, check common alternatives:

```bash
# Default install path
`/mnt/c/Program Files/draw.io/draw.io.exe`
# Per-user install (if the above does not exist)
`/mnt/c/Users/$WIN_USER/AppData/Local/Programs/draw.io/draw.io.exe`
```

#### macOS

```bash
/Applications/draw.io.app/Contents/MacOS/draw.io
```

#### Linux (native)

```bash
drawio   # typically on PATH via snap/apt/flatpak, or via AppImage symlink
```

**Architecture matters.** Check `uname -m` and match the right package:

| Host `uname -m` | Recommended install |
|-----------------|---------------------|
| `x86_64` | `drawio-x86_64-*.AppImage` or `.deb` |
| `aarch64` (ARM64, Raspberry Pi 4/5) | `drawio-arm64-*.deb` (installs to `/usr/bin/drawio`) |
| `armv7l` (32-bit ARM) | not supported — use MCP render |

**Never use an x86_64 AppImage on ARM** — it will fail with `cannot execute binary file: Exec format error`.

For x86_64-specific install / AppImage / `.deb` / headless `xvfb` details, load [`references/x86_64-install.md`](references/x86_64-install.md).

### Headless (no DISPLAY) setup — ARM64 / server / CI

On a headless machine (Pi, VPS, CI runner), drawio still needs an X server to run Electron. Use `xvfb-run` as the wrapper. The known-good pattern on Debian/Ubuntu ARM64 with the native `.deb` installed:

```bash
# 1. Install native package
sudo apt install ./drawio-arm64-*.deb  # installs /usr/bin/drawio

# 2. Create a wrapper that passes user args FIRST, Chromium flags LAST
mkdir -p ~/.local/bin
cat > ~/.local/bin/drawio-headless <<'EOF'
#!/usr/bin/env bash
ELECTRON_DISABLE_GPU=1 /usr/bin/drawio "$@" --no-sandbox --disable-gpu --disable-software-rasterizer
EOF
chmod +x ~/.local/bin/drawio-headless

# 3. Install xvfb + required libs
sudo apt install -y xvfb libasound2 libgbm1 libnss3 poppler-utils
```

**Wrapper arg order matters.** Placing user args AFTER the Chromium flags breaks drawio's Commander.js CLI parser — it consumes the input file path as if it were a Chromium flag value and reports "input file/directory not found". Always put `"$@"` before `--no-sandbox --disable-gpu --disable-software-rasterizer`.

### Export commands (headless)

```bash
# PDF — most reliable on ARM64 headless
xvfb-run -a --server-args="-screen 0 1920x1080x24" \
  drawio-headless -x -f pdf -b 10 \
  -o out.pdf in.drawio

# PNG — works for small diagrams; often fails for large or complex
# diagrams on ARM64 with "Export failed: ...". If it fails, use the
# PDF->PNG fallback below.
LIBGL_ALWAYS_SOFTWARE=1 GDK_BACKEND=x11 \
xvfb-run -a --server-args="-screen 0 1920x1080x24" \
  drawio-headless -x -f png -e -b 10 \
  -o out.drawio.png in.drawio

# PDF->PNG fallback when direct PNG export fails (poppler-utils)
pdftoppm -png -r 150 out.pdf out-base
# produces out-base-1.png
```

### Known ARM64 quirks

- **Direct PNG export can fail silently** for larger diagrams ("Export failed: <path>") even though PDF works fine on the same file. The PDF-to-PNG fallback via `pdftoppm -r 150` is visually equivalent for embedding in docs.
- **dbus warning** `Failed to call method: org.freedesktop.systemd1.Manager.StartTransientUnit` is harmless — ignore it.
- **Remove `adaptiveColors="auto"` from `<mxGraphModel>`** when writing files for CLI export — it's a UI attribute, not a file-format one, and can cause render failures on some versions.
- **`.drawio` file must have the full `<mxfile>` wrapper:**

  ```xml
  <mxfile host="app.diagrams.net" agent="..." version="...">
    <diagram name="..." id="...">
      <mxGraphModel ...>
        <root>...</root>
      </mxGraphModel>
    </diagram>
  </mxfile>
  ```

  Bare `<mxGraphModel>` works for the drawio MCP but NOT the CLI.

### Fallback: drawio MCP

If no local install works or the architecture is not supported, use `mcp__claude_ai_draw_io__create_diagram` to render `.drawio` XML inline. The source `.drawio` file remains editable in any drawio instance regardless of where it was rendered.

#### Windows (native, non-WSL2)

```
"C:\Program Files\draw.io\draw.io.exe"
```

Use `which drawio` (or `where drawio` on Windows) to check if it's on PATH before falling back to the platform-specific path.

### Export command

```bash
drawio -x -f <format> -e -b 10 -o <output> <input.drawio>
```

**WSL2 example:**

```bash
`/mnt/c/Program Files/draw.io/draw.io.exe` -x -f png -e -b 10 -o diagram.drawio.png diagram.drawio
```

Key flags:

- `-x` / `--export`: export mode
- `-f` / `--format`: output format (png, svg, pdf, jpg)
- `-e` / `--embed-diagram`: embed diagram XML in the output (PNG, SVG, PDF only)
- `-o` / `--output`: output file path
- `-b` / `--border`: border width around diagram (default: 0)
- `-t` / `--transparent`: transparent background (PNG only)
- `-s` / `--scale`: scale the diagram size
- `--width` / `--height`: fit into specified dimensions (preserves aspect ratio)
- `-a` / `--all-pages`: export all pages (PDF only)
- `-p` / `--page-index`: select a specific page (1-based)

### Opening the result

| Environment | Command |
|-------------|---------|
| macOS | `open <file>` |
| Linux (native) | `xdg-open <file>` |
| WSL2 | `cmd.exe /c start "" "$(wslpath -w <file>)"` |
| Windows | `start <file>` |

**WSL2 notes:**

- `wslpath -w <file>` converts a WSL2 path (e.g. `/home/user/diagram.drawio`) to a Windows path (e.g. `C:\Users\...`). This is required because `cmd.exe` cannot resolve `/mnt/c/...` style paths.
- The empty string `""` after `start` is required to prevent `start` from interpreting the filename as a window title.

**WSL2 example:**

```bash
cmd.exe /c start "" "$(wslpath -w diagram.drawio)"
```

## File naming

- Use a descriptive filename based on the diagram content (e.g., `login-flow`, `database-schema`).
- Use lowercase with hyphens for multi-word names.
- For export, use double extensions: `name.drawio.png`, `name.drawio.svg`, `name.drawio.pdf` — this signals the file contains embedded diagram XML.
- After a successful export of a **scratch / one-off diagram**, you may delete the intermediate `.drawio` file — the exported file contains the full diagram XML. For diagrams committed to `docs/diagrams/` or `architecture/diagrams/`, **keep both** (the standard requires it).

## XML format

A `.drawio` file is native mxGraphModel XML. Always generate XML directly — Mermaid and CSV formats require server-side conversion and cannot be saved as native files.

### Basic structure

Every diagram must have this structure:

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- Diagram cells go here with parent="1" -->
  </root>
</mxGraphModel>
```

- Cell `id="0"` is the root layer.
- Cell `id="1"` is the default parent layer.
- All diagram elements use `parent="1"` unless using multiple layers.

For CLI-exported files, wrap with `<mxfile>` as shown in [Known ARM64 quirks](#known-arm64-quirks) above.

## XML reference

For the complete drawio XML reference including common styles, edge routing, containers, layers, tags, metadata, dark mode colors, and XML well-formedness rules, fetch and follow the instructions at:

<https://raw.githubusercontent.com/jgraph/drawio-mcp/main/shared/xml-reference.md>

## Reference files (load on demand)

| File | Load when... |
|------|--------------|
| [`references/edge-routing.md`](references/edge-routing.md) | Edges wrap around boxes awkwardly, cross unrelated shapes, or exit from visually wrong sides. Covers connection points (exitX/Y, entryX/Y), waypoints, container zones, corridors, and the decision tree for common routing problems. |
| [`references/x86_64-install.md`](references/x86_64-install.md) | Installing or exporting drawio on a standard x86_64 Linux/macOS/Windows host. Covers AppImage, `.deb`, headless xvfb, and smoke test. |

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| drawio CLI not found | Desktop app not installed or not on PATH | Keep the `.drawio` file and tell the user to install the drawio desktop app, or open the file manually |
| Export produces empty/corrupt file | Invalid XML (e.g. double hyphens in comments, unescaped special characters) | Validate XML well-formedness before writing; see [§CRITICAL: XML well-formedness](#critical-xml-well-formedness) below |
| Diagram opens but looks blank | Missing root cells `id="0"` and `id="1"` | Ensure the basic mxGraphModel structure is complete |
| Edges not rendering | Edge mxCell is self-closing (no child mxGeometry element) | Every edge must have `<mxGeometry relative="1" as="geometry" />` as a child element |
| File won't open after export | Incorrect file path or missing file association | Print the absolute file path so the user can open it manually |

## CRITICAL: XML well-formedness

- **NEVER include ANY XML comments (`<!-- -->`) in the output.** XML comments are strictly forbidden — they waste tokens, can cause parse errors, and serve no purpose in diagram XML.
- Escape special characters in attribute values: `&amp;`, `&lt;`, `&gt;`, `&quot;`.
- Always use unique `id` values for each `mxCell`.

<!-- Shim generated from .agents/skills/drawio/SKILL.md by scripts/sync-agent-skills.sh -->
<!-- Customize vendor-specific bits (argument hints, slash-command semantics, tool calls) here. -->
<!-- For procedure/output changes, edit the canonical first. -->
