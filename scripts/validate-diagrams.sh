#!/usr/bin/env bash
# validate-diagrams.sh
#
# Drift + quality gate for committed diagrams, closing the loop sketched
# in standards/diagramming-conventions.md §Drift mitigation.
#
# Three checks per reference diagram (a `.drawio` under the repo's
# diagrams directory, EXCLUDING the templates/ and styles/ subdirs):
#
#   1. Paired SVG exists. The standard requires every committed diagram
#      to ship a rendered `.svg` alongside the source. Accepts either
#      `<name>.svg` or `<name>.drawio.svg`. Missing -> ERROR.
#
#   2. Source-of-truth footer present + fresh. The `.drawio` must carry
#      a `Last reviewed: YYYY-MM-DD` footer.
#        - Missing footer            -> ERROR (always).
#        - Stale (> --stale-days old):
#            * full scan             -> WARN  (surfaced at review time).
#            * the diagram is in the
#              changeset (passed as
#              an argument / by the
#              pre-commit hook)      -> ERROR (you edited a stale diagram;
#                                              re-review and bump the date).
#
#   3. Contrast lint (WCAG 2.1 AA, heuristic). For each text-bearing
#      cell, compute the contrast ratio of `fontColor` against its
#      background (the cell's `fillColor`, or white if the cell has no
#      fill). Flags ratios below the floor (4.5:1 body / 3:1 large text,
#      where large = fontSize>=18 or >=14 bold). Heuristic — the
#      white-background assumption can't see a coloured shape sitting
#      behind a standalone text element — so contrast findings are WARN
#      by default and ERROR only under --strict.
#
# Usage:
#   scripts/validate-diagrams.sh [--strict] [--stale-days N] [TARGET ...]
#
#   No TARGET           -> full scan of this repo's diagrams directory.
#   TARGET = directory  -> full scan of that directory tree.
#   TARGET = .drawio    -> changeset mode for those files (stale = ERROR).
#                          This is how the pre-commit hook invokes it.
#
# Mode auto-detect (same sentinel as repo-healthcheck.sh): the
# architecture repo ships standards/repo-contract.md and keeps diagrams
# under architecture/diagrams/; a consuming repo keeps them under
# docs/diagrams/.
#
# Exit codes:
#   0  PASS — no errors (warnings allowed)
#   1  FAIL — one or more errors
#   2  invocation error
#
# Note: uses GNU `date -d` for date math (Linux CI / dev). Not portable
# to BSD/macOS `date` without coreutils.

set -uo pipefail

STRICT=0
STALE_DAYS=90
declare -a TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=1; shift ;;
    --stale-days) STALE_DAYS="${2:-90}"; shift 2 ;;
    --stale-days=*) STALE_DAYS="${1#*=}"; shift ;;
    -h|--help)
      sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    --) shift; while [[ $# -gt 0 ]]; do TARGETS+=("$1"); shift; done ;;
    -*) echo "ERROR: unknown flag: $1" >&2; exit 2 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done

if ! [[ "$STALE_DAYS" =~ ^[0-9]+$ ]]; then
  echo "ERROR: --stale-days must be an integer" >&2
  exit 2
fi

ERR=0
WARN=0
err()  { echo "[ERROR]   $*" >&2; ERR=$((ERR + 1)); }
warn() { echo "[WARN]    $*" >&2; WARN=$((WARN + 1)); }
ok()   { echo "[OK]      $*"; }
info() { echo "[INFO]    $*"; }

TODAY_EPOCH="$(date +%s)"

# ---------- diagram discovery ----------

# Reference diagrams live at the top of the diagrams directory; the
# templates/ subdir (placeholder footers) and styles/ subdir (the swatch
# library) have their own conventions and are excluded.
is_excluded() {
  case "$1" in
    */templates/*|*/styles/*) return 0 ;;
    *) return 1 ;;
  esac
}

declare -a DIAGRAMS=()
CHANGESET_MODE=0

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  # Full scan. Pick the diagrams directory by sentinel.
  if [[ -f standards/repo-contract.md ]]; then
    SCAN_DIR="architecture/diagrams"
  else
    SCAN_DIR="docs/diagrams"
  fi
  if [[ ! -d "$SCAN_DIR" ]]; then
    info "no diagrams directory at $SCAN_DIR/ — nothing to validate"
    echo
    echo "validate-diagrams: PASS"
    exit 0
  fi
  while IFS= read -r f; do
    is_excluded "$f" && continue
    DIAGRAMS+=("$f")
  done < <(find "$SCAN_DIR" -type f -name '*.drawio' | sort)
else
  CHANGESET_MODE=1
  for t in "${TARGETS[@]}"; do
    if [[ -d "$t" ]]; then
      CHANGESET_MODE=0
      while IFS= read -r f; do
        is_excluded "$f" && continue
        DIAGRAMS+=("$f")
      done < <(find "$t" -type f -name '*.drawio' | sort)
    elif [[ "$t" == *.drawio ]]; then
      is_excluded "$t" && continue
      [[ -f "$t" ]] && DIAGRAMS+=("$t")
    fi
    # silently ignore non-.drawio args (pre-commit may pass .svg too)
  done
fi

if [[ ${#DIAGRAMS[@]} -eq 0 ]]; then
  info "no reference diagrams to validate (templates/ and styles/ excluded)"
  echo
  echo "validate-diagrams: PASS"
  exit 0
fi

# ---------- contrast helper (WCAG 2.1 relative luminance) ----------

# contrast_ratio "#rrggbb" "#rrggbb" -> prints ratio to 2 dp.
# Hex is parsed to decimal in bash ($((16#..)) handles upper/lowercase)
# and passed to awk as integers, so this works with mawk (no strtonum).
contrast_ratio() {
  local a="${1#\#}" b="${2#\#}"
  local ar=$((16#${a:0:2})) ag=$((16#${a:2:2})) ab=$((16#${a:4:2}))
  local br=$((16#${b:0:2})) bg=$((16#${b:2:2})) bb=$((16#${b:4:2}))
  awk -v ar="$ar" -v ag="$ag" -v ab="$ab" -v br="$br" -v bg="$bg" -v bb="$bb" '
    function chan(v) { v = v/255.0;
      return (v <= 0.03928) ? v/12.92 : exp(2.4*log((v+0.055)/1.055)) }
    function lum(r,g,b) { return 0.2126*chan(r) + 0.7152*chan(g) + 0.0722*chan(b) }
    BEGIN {
      la = lum(ar,ag,ab); lb = lum(br,bg,bb);
      hi = (la > lb) ? la : lb; lo = (la > lb) ? lb : la;
      printf "%.2f", (hi + 0.05) / (lo + 0.05);
    }'
}

# extract a style attribute value: style_attr "<style string>" fontColor
style_attr() {
  local style="$1" key="$2"
  # match key=value up to ; or end
  printf '%s' "$style" | grep -oE "(^|;)${key}=[^;\"]*" | head -1 | sed -E "s/.*${key}=//"
}

# ---------- per-diagram checks ----------

for d in "${DIAGRAMS[@]}"; do
  base="${d%.drawio}"
  name="$(basename "$d")"

  # ---- 1. paired SVG ----
  if [[ -f "${base}.svg" || -f "${d}.svg" ]]; then
    ok "$name — paired SVG present"
  else
    err "$name — no paired SVG (expected ${name%.drawio}.svg or ${name}.svg). The standard requires a rendered SVG alongside every committed diagram."
  fi

  # ---- 2. footer present + fresh ----
  reviewed="$(grep -oE 'Last reviewed:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$d" | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"
  if [[ -z "$reviewed" ]]; then
    err "$name — no 'Last reviewed: YYYY-MM-DD' footer (standard §Source-of-truth linkage)."
  else
    rev_epoch="$(date -d "$reviewed" +%s 2>/dev/null || echo "")"
    if [[ -z "$rev_epoch" ]]; then
      err "$name — 'Last reviewed: $reviewed' is not a valid date."
    else
      age_days=$(( (TODAY_EPOCH - rev_epoch) / 86400 ))
      if (( age_days > STALE_DAYS )); then
        if (( CHANGESET_MODE == 1 )); then
          err "$name — Last reviewed $reviewed is ${age_days}d old (> ${STALE_DAYS}d) and the diagram is being changed. Re-review and bump the date."
        else
          warn "$name — Last reviewed $reviewed is ${age_days}d old (> ${STALE_DAYS}d). Re-review at the next quarterly pass."
        fi
      else
        ok "$name — Last reviewed $reviewed (${age_days}d old)"
      fi
    fi
  fi

  # ---- 3. contrast lint ----
  # Examine each cell style with a fontColor; compute ratio vs fillColor
  # (or white). Skip cells whose text is empty.
  while IFS= read -r style; do
    fc="$(style_attr "$style" fontColor)"
    [[ -z "$fc" || "$fc" == "none" ]] && continue
    [[ "$fc" =~ ^#[0-9A-Fa-f]{6}$ ]] || continue
    bg="$(style_attr "$style" fillColor)"
    if [[ -z "$bg" || "$bg" == "none" ]]; then bg="#ffffff"; fi
    [[ "$bg" =~ ^#[0-9A-Fa-f]{6}$ ]] || continue
    fsize="$(style_attr "$style" fontSize)"; fsize="${fsize:-12}"
    fstyle="$(style_attr "$style" fontStyle)"; fstyle="${fstyle:-0}"
    # large text: >=18, or >=14 and bold (fontStyle bit 1 set: 1 or 3)
    floor="4.5"
    if (( fsize >= 18 )) || { (( fsize >= 14 )) && { [[ "$fstyle" == "1" || "$fstyle" == "3" ]]; }; }; then
      floor="3.0"
    fi
    ratio="$(contrast_ratio "$fc" "$bg")"
    below="$(awk -v r="$ratio" -v f="$floor" 'BEGIN{print (r < f) ? 1 : 0}')"
    if [[ "$below" == "1" ]]; then
      msg="$name — contrast ${ratio}:1 (floor ${floor}:1) for fontColor=$fc on $bg"
      if (( STRICT == 1 )); then err "$msg"; else warn "$msg (heuristic — verify; pass --strict to fail on this)"; fi
    fi
  done < <(grep -oE 'style="[^"]*fontColor=[^"]*"' "$d" | sed -E 's/^style="//; s/"$//')
done

# ---------- summary ----------

echo
echo "validate-diagrams: ${#DIAGRAMS[@]} diagram(s) checked · ${ERR} error(s) · ${WARN} warning(s)"
if (( ERR > 0 )); then
  echo "validate-diagrams: FAIL"
  exit 1
fi
echo "validate-diagrams: PASS"
exit 0
