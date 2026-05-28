# drawio install — x86_64 hosts

Load this file when installing or exporting drawio on a standard x86_64 Linux, macOS, or Windows host. Covers AppImage, `.deb`, headless `xvfb`, and a smoke test. For ARM64 / headless Linux (Raspberry Pi, ARM VPS, ARM CI), use the headless section in [`../SKILL.md`](../SKILL.md) — the wrapper-arg ordering and `.deb` path matter there in ways that don't apply here.

---

## macOS

Download the `.dmg` from <https://github.com/jgraph/drawio-desktop/releases>, mount it, drag drawio to `/Applications/`. The CLI is at:

```bash
/Applications/draw.io.app/Contents/MacOS/draw.io
```

If you want it on PATH:

```bash
sudo ln -sf /Applications/draw.io.app/Contents/MacOS/draw.io /usr/local/bin/drawio
```

Smoke test:

```bash
drawio --version
```

---

## Linux (x86_64 desktop)

Three install paths, in rough order of preference:

### `.deb` (Debian / Ubuntu / Mint)

```bash
# Download the latest x86_64 .deb from the releases page
DRAWIO_DEB=drawio-amd64-*.deb
sudo apt install ./$DRAWIO_DEB
# Installs to /usr/bin/drawio
```

### `.rpm` (Fedora / RHEL / openSUSE)

```bash
DRAWIO_RPM=drawio-x86_64-*.rpm
sudo dnf install ./$DRAWIO_RPM  # or rpm -i
```

### AppImage (any glibc-based distro)

AppImages are portable but need FUSE 2.

```bash
chmod +x ~/Downloads/drawio-x86_64-*.AppImage
mkdir -p ~/.local/bin
ln -sf ~/Downloads/drawio-x86_64-*.AppImage ~/.local/bin/drawio
```

If you see `dlopen(): error loading libfuse.so.2`, install FUSE:

```bash
sudo apt install libfuse2     # Debian / Ubuntu
sudo dnf install fuse-libs    # Fedora
```

---

## Linux (x86_64 headless — server / CI runner / VPS)

The desktop app still uses Electron, which needs an X server. Use `xvfb-run`:

```bash
# Install
sudo apt install ./drawio-amd64-*.deb
sudo apt install -y xvfb libasound2 libgbm1 libnss3 poppler-utils

# Wrapper — user args FIRST, Chromium flags LAST (same constraint as ARM64)
mkdir -p ~/.local/bin
cat > ~/.local/bin/drawio-headless <<'EOF'
#!/usr/bin/env bash
ELECTRON_DISABLE_GPU=1 /usr/bin/drawio "$@" --no-sandbox --disable-gpu --disable-software-rasterizer
EOF
chmod +x ~/.local/bin/drawio-headless
```

Smoke test:

```bash
xvfb-run -a drawio-headless --version
```

Export test (run from a directory with any `.drawio` file):

```bash
xvfb-run -a --server-args="-screen 0 1920x1080x24" \
  drawio-headless -x -f svg -e -b 10 \
  -o smoke.drawio.svg in.drawio
```

x86_64 generally has fewer of the silent-PNG-failure problems that plague ARM64 — direct PNG export usually works. If it doesn't, the same PDF → PNG fallback (`pdftoppm -png -r 150`) applies.

---

## Windows (native, non-WSL2)

Download and run the installer from the releases page. Default install path:

```
C:\Program Files\draw.io\draw.io.exe
```

For CMD / PowerShell:

```cmd
"C:\Program Files\draw.io\draw.io.exe" --version
```

For Git Bash / MSYS2:

```bash
"/c/Program Files/draw.io/draw.io.exe" --version
```

For WSL2, use the Windows executable via `/mnt/c/...` per the main `SKILL.md`.

---

## Verifying the install end-to-end

A round-trip smoke test:

```bash
# 1. Write a minimal .drawio
cat > smoke.drawio <<'EOF'
<mxfile host="app.diagrams.net" agent="smoke" version="22.0.0">
  <diagram name="Smoke" id="smoke">
    <mxGraphModel>
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <mxCell id="2" value="Hello" vertex="1" parent="1"
          style="rounded=1;fillColor=#dae8fc;strokeColor=#6c8ebf;">
          <mxGeometry x="40" y="40" width="120" height="60" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
EOF

# 2. Export to SVG
drawio -x -f svg -e -b 10 -o smoke.drawio.svg smoke.drawio

# 3. Confirm the SVG renders (in a browser or via `file`)
file smoke.drawio.svg
# Expected: "SVG Scalable Vector Graphics image"
```

If step 2 succeeds and step 3 reports SVG, the install is good.

---

## Failure modes

| Symptom | Likely cause | Fix |
|---|---|---|
| `command not found: drawio` | Not on PATH | Add the symlink shown above, or use the absolute path |
| `cannot execute binary file: Exec format error` | x86_64 AppImage on ARM64 host | Use the ARM64 `.deb` instead (see main `SKILL.md`) |
| `dlopen(): error loading libfuse.so.2` | AppImage needs FUSE, not installed | `sudo apt install libfuse2` |
| Export hangs forever | Headless without `xvfb` | Wrap with `xvfb-run -a`, or use `pdftoppm` fallback |
| Empty / 0-byte output file | Malformed XML (likely `<!--` comment, unescaped `&`) | Validate the `.drawio` file opens in drawio Desktop first |
| `Export failed: <path>` (PNG only) | Known PNG-render edge case | Export PDF then convert via `pdftoppm -png -r 150` |
