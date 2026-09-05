#!/usr/bin/env bash
# One reader splits every tab-delimited row this repository reads, and
# this is the property that made it one reader. A tab is an IFS
# *whitespace* character, so `IFS="$TAB" read -r a b c` folds a run of
# tabs into one separator: an empty field vanishes and every field after
# it shifts left. `gh` emits `author.login` as the empty string for a
# pull request whose author deleted their account, so the empty field
# arrives without anybody typing one.
#
# Sources the harness directly: ql_row_fields reads no repository.
. "$(dirname "$0")/../../harness.sh"

QUEUE_LIB="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/queue_lib.sh"

# fields <count> <row> — the fields the reader found, one per line, with
# each empty one shown as `<empty>` so a vanished field is visible rather
# than blending into the line above it.
fields() {
  bash -c '
    set -euo pipefail
    . "$0"
    ql_row_fields "$1" "$2" || { echo "SHORT"; exit 0; }
    i=1
    while [ "$i" -le "$1" ]; do
      eval "v=\$QL_F$i"
      [ -n "$v" ] || v="<empty>"
      printf "%s\n" "$v"
      i=$((i + 1))
    done
  ' "$QUEUE_LIB" "$1" "$2"
}

# exact <name> <want> -- <cmd...> — the whole of stdout, byte for byte.
# A substring cannot assert that a field is in its own position.
exact() {
  local name="$1" want="$2"; shift 3
  local out
  out=$("$@")
  if [ "$out" = "$want" ]; then
    printf 'ok    %s\n' "$name"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected:\n%s\n      got:\n%s\n' \
      "$name" "$(printf '%s\n' "$want" | sed 's/^/        /')" \
      "$(printf '%s\n' "$out" | sed 's/^/        /')"
    fail=$((fail + 1))
  fi
}

TAB=$(printf '\t')

# The deleted account, which is the fixture because it is the real one.
exact "an empty author leaves every later field in place" \
  "$(printf '12\ndocs/an-aside\n<empty>\nfalse\n[TASK-0031][Feat][Ci] The aside')" \
  -- fields 5 "12${TAB}docs/an-aside${TAB}${TAB}false${TAB}[TASK-0031][Feat][Ci] The aside"

# Two empty fields running together are two fields, not one and not none.
exact "two adjacent empty fields stay two" \
  "$(printf '7\n<empty>\n<empty>\nlast')" \
  -- fields 4 "7${TAB}${TAB}${TAB}last"

# The last field takes the remainder. A title carrying a literal tab is
# the author's to write, and the fragment after it is title, never a
# later field — there is no later field to be.
exact "a tab inside the last field does not start another" \
  "$(printf '9\ntask/0009-x\n[Feat] before%safter' "$TAB")" \
  -- fields 3 "9${TAB}task/0009-x${TAB}[Feat] before${TAB}after"

# A row with fewer separators than fields asked for is a row this reader
# cannot answer. Returning 1 is what lets a caller skip it; reading it
# short would hand the caller a field it never had.
exact "a row too short is refused, not read short" \
  "SHORT" \
  -- fields 5 "12${TAB}docs/an-aside${TAB}false"

# An empty leading field is the one `read` also loses to IFS whitespace
# stripping, before any collapse.
exact "an empty leading field is a field" \
  "$(printf '<empty>\nb\nc')" \
  -- fields 3 "${TAB}b${TAB}c"

finish
