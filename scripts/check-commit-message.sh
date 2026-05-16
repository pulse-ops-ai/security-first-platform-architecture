#!/usr/bin/env bash
# check-commit-message.sh
#
# Validates that a commit message follows the Conventional Commits
# prefix convention used throughout this repo's history. This is a
# pragmatic subset, not the full Conventional Commits 1.0 spec — we
# enforce the prefix shape; we don't enforce body-line wrapping,
# imperative-mood headlines, or scope syntax beyond the allowed set.
#
# Invoked by pre-commit as a `commit-msg` hook. The hook receives the
# path to the commit message file as $1.
#
# Allowed prefixes (mirror the history this repo has so far):
#
#   chore:        — housekeeping, dep bumps, config
#   feat:         — user-facing or contract-facing addition
#   fix:          — bug fix
#   docs:         — documentation only
#   refactor:     — code change that's neither a fix nor a feat
#   test:         — adding or refining tests
#   style:        — formatting; no behavior change
#   perf:         — performance
#   ci:           — CI configuration
#   build:        — build system or external deps
#   revert:       — revert of a prior commit
#   openspec:     — OpenSpec proposal lifecycle (open/accept/archive)
#
# Optional scope in parens: `feat(scope): ...`. Allowed scopes are not
# restricted by this hook.
#
# Optional breaking-change marker: `feat!: ...` or `feat(scope)!: ...`.
#
# Exit codes:
#   0  message accepted
#   1  message rejected (CI / hook blocks the commit)
#   2  invocation error

set -uo pipefail

if [[ $# -lt 1 ]]; then
  echo "ERROR: usage: $0 <commit-message-file>" >&2
  exit 2
fi

MSG_FILE="$1"

if [[ ! -f "$MSG_FILE" ]]; then
  echo "ERROR: commit message file not found: $MSG_FILE" >&2
  exit 2
fi

# Strip comments and trailing whitespace from the first non-blank line.
FIRST_LINE="$(grep -v '^#' "$MSG_FILE" | sed -n '/^[^[:space:]]/{p;q}')"

if [[ -z "$FIRST_LINE" ]]; then
  echo "ERROR: commit message is empty" >&2
  exit 1
fi

# Conventional Commits regex.
#   type(scope)!?: description
# - type: one of the allowed prefixes
# - scope: optional, alphanumeric + hyphen/dot/underscore/slash
# - !?:    optional breaking-change marker before the colon
# - description: at least one non-space character after the colon+space
PATTERN='^(chore|feat|fix|docs|refactor|test|style|perf|ci|build|revert|openspec)(\([a-zA-Z0-9._/-]+\))?!?:[[:space:]]+.+'

# Allow merge commits (GitHub's default merge style).
if [[ "$FIRST_LINE" =~ ^Merge[[:space:]] ]]; then
  exit 0
fi

# Allow revert commits with the default `Revert "..."` format.
if [[ "$FIRST_LINE" =~ ^Revert[[:space:]]\".+\"$ ]]; then
  exit 0
fi

if [[ "$FIRST_LINE" =~ $PATTERN ]]; then
  exit 0
fi

cat >&2 <<EOF
ERROR: commit message does not follow the conventional-commits prefix.

Got:
  $FIRST_LINE

Expected one of these prefixes, optionally with scope and breaking-change marker:

  chore:    feat:    fix:      docs:    refactor:
  test:     style:   perf:     ci:      build:
  revert:   openspec:

Examples:
  feat(adoption): add security-first-adoption record template
  fix(codeowners): add /SECURITY.md ownership
  docs(scripts): document check-inline-secrets.sh
  feat!: break envelope schema and supersede prior contract
  openspec(2026-05-16): archive enforcement-and-skill-rigor proposal

Merge commits and "Revert ..." commits are exempt.
EOF
exit 1
