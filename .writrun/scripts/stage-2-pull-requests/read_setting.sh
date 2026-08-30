#!/usr/bin/env bash
# read_setting.sh — prints one value from .writrun/conventions/settings.json.
#
# Usage: read_setting.sh <key>
#   Run from the repository root; the path is relative to it.
#
# The file is JSON in a restricted shape — flat object, one `"key": value`
# per line, values `true`, `false`, an unquoted integer, or a double-quoted
# string (docs/technical/README.md#the-shape-is-a-checked-contract). That
# restriction is what lets this read it with `sed` alone: requiring `jq`
# would be this project's first runtime dependency, which the toolchain is
# built to avoid.
#
# **Absence is not an error.** No file, or no such key, prints the
# documented default — the same posture list_tasks.sh takes when no forge
# answers. An adopter who deletes the file keeps working, with the
# behaviour the schema documents; a reader that failed instead would make
# the file mandatory, which it is not.
#
# A key the schema does not document has no documented default, so it
# prints nothing. Exit is still 0: this reads a value, it does not judge
# the file — check_settings.sh does that.
#
# Exit codes: 0 always, except 3 for a usage error.
#
# Portable bash 3.2, POSIX awk/sed. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail

KEY="${1:-}"
[ -n "$KEY" ] || { echo "usage: read_setting.sh <key>" >&2; exit 3; }

SETTINGS=".writrun/conventions/settings.json"

# The documented defaults, which are the values the schema's own example
# block carries (docs/technical/README.md#settings). They are the stage
# and style this machinery behaved at before the file existed, so a
# project without one behaves exactly as it did.
default_for() {
  case "$1" in
    stage)          printf '3' ;;
    pr_title_style) printf 'conventional' ;;
  esac
}

[ -f "$SETTINGS" ] || { default_for "$KEY"; echo; exit 0; }

# Everything after the first colon that follows the key, so a quoted value
# holding a colon of its own ("status:") survives intact.
raw=$(sed -n "s/^[[:space:]]*\"${KEY}\"[[:space:]]*:[[:space:]]*\(.*\)$/\1/p" \
  "$SETTINGS" | head -n1)

if [ -z "$raw" ] && [ "$KEY" = "stage" ]; then
  # The migration bridge: a settings file written before the rename
  # says `level`, and reading it as "absent, so the default" would turn
  # every workflow on for an adopter who chose the full opt-out.
  # check_settings.sh names the rename; this keeps their choice honoured
  # until they make it.
  legacy=$(sed -n 's/^[[:space:]]*"level"[[:space:]]*:[[:space:]]*\(.*\)$/\1/p' \
    "$SETTINGS" | head -n1 | sed 's/[[:space:]]*$//; s/,$//; s/^"//; s/"$//')
  case "$legacy" in
    tasks-and-specs) printf '1\n'; exit 0 ;;
    pull-requests)   printf '2\n'; exit 0 ;;
    github-issues)   printf '3\n'; exit 0 ;;
  esac
fi

if [ -z "$raw" ]; then
  default_for "$KEY"; echo; exit 0
fi

# Trailing whitespace, then the separating comma, then the quotes.
val=$(printf '%s' "$raw" | sed 's/[[:space:]]*$//')
val=${val%,}
val=$(printf '%s' "$val" | sed 's/[[:space:]]*$//')
case "$val" in
  \"*\") val=${val#\"}; val=${val%\"} ;;
esac

printf '%s\n' "$val"
