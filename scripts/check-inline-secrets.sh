#!/usr/bin/env bash
#
# check-inline-secrets.sh
#
# Block inline secrets in YAML, env-style, and JSON config files.
#
# This is a focused complement to detect-secrets:
#   - detect-secrets catches high-entropy strings and well-known patterns.
#   - This script catches the specific shape of "sensitive key assigned a
#     literal value" - including credentials hidden behind shell-style
#     defaults like ${VAR:-literal}, which detect-secrets typically misses.
#
# A finding is reported when a sensitive key (e.g. KAFKA_SASL_PASSWORD) is
# given a literal value rather than:
#   - an empty string
#   - a placeholder (your-*, <example>, xxxx, changeme, ...)
#   - a pure environment reference (${VAR}, ${VAR:-})
#   - a pure environment reference with a placeholder default (${VAR:-your-*})
#
# Output never prints the suspected secret value - only file:line:key.
#
# Usage:
#   tools/security/check-inline-secrets.sh                # scan tracked config files
#   tools/security/check-inline-secrets.sh path1 path2    # scan specific files (pre-commit hook mode)

set -u

# Sensitive keys we never want to see assigned a literal value.
# Add new keys here as the surface grows.
SENSITIVE_KEYS=(
)

# Files we deliberately scan even if they look like fixtures, because real
# credentials have leaked into them historically.
# (Documentation of the active surface; main() inlines the same list into
# git ls-files. shellcheck disable is intentional.)
# shellcheck disable=SC2034
INCLUDE_GLOBS=(
  '*.yml'
  '*.yaml'
  '*.env'
  '*.env.*'
  '.env'
  '.env.*'
  '*.json'
  '*.tf'
  '*.tfvars'
  '*.sh'
)

# Paths that may legitimately contain placeholder-style examples. These are
# still scanned, but a placeholder value will not trigger a finding. Real
# compose files are NOT excluded.
# (Reserved for future per-path policy; kept documented here.)
# shellcheck disable=SC2034
PLACEHOLDER_PATH_REGEX='(\.env\.example(\.template)?$|/templates/.*\.env)'

is_placeholder_value() {
  # Returns 0 if the value looks like a safe placeholder, 1 otherwise.
  local value="$1"

  # Empty value
  if [[ -z "$value" ]]; then
    return 0
  fi

  # Pure env ref: ${VAR}, ${VAR:-}, ${VAR:?...}
  if [[ "$value" =~ ^\$\{[A-Za-z_][A-Za-z0-9_]*(:[-?][^}]*)?\}$ ]]; then
    # If there is a default after :- and that default is itself a literal,
    # the calling regex layer also pulled it out separately. Here we just
    # confirm the pure ref form is fine.
    return 0
  fi

  # GitHub Actions expression: ${{ secrets.X }}, ${{ vars.X }}, ${{ env.X }},
  # ${{ inputs.X }}. These resolve at runtime from GitHub-managed secrets and
  # are not literal values.
  if [[ "$value" =~ ^\$\{\{[[:space:]]*(secrets|vars|env|inputs|github)\.[A-Za-z0-9_]+[[:space:]]*\}\}$ ]]; then
    return 0
  fi
  if [[ "$value" =~ ^[\"\']\$\{\{[[:space:]]*(secrets|vars|env|inputs|github)\.[A-Za-z0-9_]+[[:space:]]*\}\}[\"\']$ ]]; then
    return 0
  fi

  # Common placeholder words
  case "$value" in
    your-*|YOUR-*|YOUR_*|your_*) return 0 ;;
    '<example>'|'<placeholder>'|'<value>'|'<api-key>'|'<api-secret>'|'<password>'|'<client-id>'|'<client-secret>'|'<refresh-token>') return 0 ;;
    changeme|CHANGEME|example|EXAMPLE|placeholder|PLACEHOLDER) return 0 ;;
    'xxx'|'xxxx'|'xxxxx'|'xxxxxx') return 0 ;;
    'TODO'|'FIXME') return 0 ;;
  esac

  # Quoted versions of the same
  if [[ "$value" =~ ^[\"\']your-.*[\"\']$ ]]; then return 0; fi
  if [[ "$value" =~ ^[\"\']\<.*\>[\"\']$ ]]; then return 0; fi

  # Looks like a hostname-only placeholder (no credentials)
  if [[ "$value" == localhost* || "$value" == 127.0.0.1* || "$value" == 0.0.0.0* ]]; then
    return 0
  fi

  return 1
}

extract_default() {
  # Given a value, if it is of the form ${VAR:-DEFAULT}, echo DEFAULT.
  # Otherwise echo the value unchanged.
  local value="$1"
  if [[ "$value" =~ ^\$\{[A-Za-z_][A-Za-z0-9_]*:-(.*)\}$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return
  fi
  # Also handle quoted form: "${VAR:-DEFAULT}"
  if [[ "$value" =~ ^[\"\']\$\{[A-Za-z_][A-Za-z0-9_]*:-(.*)\}[\"\']$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return
  fi
  echo "$value"
}

strip_quotes() {
  local value="$1"
  # Strip surrounding double or single quotes once.
  if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo "$value"
  fi
}

scan_file() {
  local file="$1"
  local findings=0

  [[ -f "$file" ]] || return 0

  # Skip non-config files even if passed (pre-commit will pass everything
  # in the staged set; we filter by extension here).
  case "$file" in
    *.yml|*.yaml|*.env|*.env.*|*.json|*.tf|*.tfvars|*.sh)
      :
      ;;
    *)
      # Allow matching for files like "python/.env" (no extension after dot)
      case "$(basename "$file")" in
        .env|.env.*|*.env|*.env.*) : ;;
        *) return 0 ;;
      esac
      ;;
  esac

  local lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))

    # Ignore comments
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    for key in "${SENSITIVE_KEYS[@]}"; do
      # Match KEY: value (YAML) or KEY=value (env / shell) or "KEY": "value" (JSON).
      # Capture group 2 is the assigned value (raw, may include quotes).
      local value=""
      if [[ "$line" =~ (^|[[:space:]])"${key}"[[:space:]]*[:=][[:space:]]*([^[:space:]].*)$ ]]; then
        value="${BASH_REMATCH[2]}"
      elif [[ "$line" =~ \"${key}\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]]; then
        # JSON form: "KEY": "value"
        value="\"${BASH_REMATCH[1]}\""
      else
        continue
      fi

      # Trim trailing comments and whitespace from YAML/env values.
      value="${value%%#*}"
      # Trim trailing whitespace
      value="${value%"${value##*[![:space:]]}"}"

      # If the value is a ${VAR:-DEFAULT} form, the DEFAULT is what would
      # actually be used at runtime - that's the string we must validate.
      local effective
      effective="$(extract_default "$value")"
      effective="$(strip_quotes "$effective")"

      if ! is_placeholder_value "$effective"; then
        # Print file:line:key only - never the value.
        printf 'inline-secret: %s:%d: %s assigned a literal value\n' \
          "$file" "$lineno" "$key" >&2
        findings=$((findings + 1))
      fi
    done
  done < "$file"

  return "$findings"
}

main() {
  local total=0
  local files=()

  if [[ "$#" -gt 0 ]]; then
    files=("$@")
  else
    # Default: scan all tracked files matching INCLUDE_GLOBS, excluding
    # node_modules, build outputs, and the secrets baseline.
    if ! command -v git >/dev/null 2>&1; then
      echo "git not found" >&2
      exit 2
    fi
    while IFS= read -r f; do
      case "$f" in
        node_modules/*|*/node_modules/*) continue ;;
        dist/*|*/dist/*|build/*|*/build/*) continue ;;
        .secrets.baseline|*/.secrets.baseline) continue ;;
        pnpm-lock.yaml|*/pnpm-lock.yaml|package-lock.json|*/package-lock.json|yarn.lock|*/yarn.lock) continue ;;
        .venv/*|*/.venv/*|.mypy_cache/*|*/.mypy_cache/*|.ruff_cache/*|*/.ruff_cache/*) continue ;;
      esac
      files+=("$f")
    done < <(git ls-files \
      '*.yml' '*.yaml' '*.env' '*.env.*' '.env' '.env.*' \
      '*.json' '*.tf' '*.tfvars' '*.sh' 2>/dev/null)
  fi

  for f in "${files[@]}"; do
    scan_file "$f"
    total=$((total + $?))
  done

  if [[ "$total" -gt 0 ]]; then
    echo "" >&2
    echo "Found $total inline-secret violation(s). Move literal values to .env (gitignored) or a secret manager." >&2
    echo "If a finding is a known-safe placeholder, extend the placeholder rules in tools/security/check-inline-secrets.sh." >&2
    exit 1
  fi
  exit 0
}

main "$@"
