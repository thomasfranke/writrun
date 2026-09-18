#!/usr/bin/env bash
# The Values column of schema.md is where a person reads the vocabulary;
# ql_vocabulary is where the machinery does. A value added to one alone
# is the drift this case exists to fail on, key by key (decision 0079).
#
# Sources the harness directly: it reads two files and no repository.
. "$(dirname "$0")/../../harness.sh"

SCHEMA="$REPO_ROOT/docs/technical/settings/schema.md"
QUEUE_LIB="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/queue_lib.sh"

# The table's rows, as `<address> <expected vocabulary>` — the expected
# vocabulary being the backticked alternatives of the Values cell, and
# empty where the cell states a shape instead of a list. A cell counts as
# a vocabulary only when *every* alternative is a backticked literal, so
# "lower-case words, space-separated" is read as free-form rather than as
# one long value.
rows() {
  awk -F'|' '
    NF >= 5 && $2 ~ /^ *`[a-z_]+` *$/ {
      key = $2; sec = $3; val = $4
      gsub(/^ +| +$/, "", key); gsub(/`/, "", key)
      gsub(/^ +| +$/, "", sec); gsub(/`/, "", sec)
      gsub(/^ +| +$/, "", val)
      address = (sec == "top level") ? key : sec "." key

      n = split(val, alt, / \/ /)
      vocab = ""; closed = 1
      for (i = 1; i <= n; i++) {
        a = alt[i]
        gsub(/^ +| +$/, "", a)
        if (a !~ /^`[^`]+`$/) { closed = 0; break }
        gsub(/`/, "", a)
        vocab = (vocab == "") ? a : vocab " " a
      }
      print address "\t" (closed ? vocab : "")
    }
  ' "$SCHEMA"
}

# What the home answers for the same address, one line per key, in the
# table's own order — so a mismatch prints as a diff of two lists rather
# than as a count.
home() {
  while IFS="$(printf '\t')" read -r address _; do
    [ -n "$address" ] || continue
    printf '%s\t%s\n' "$address" \
      "$(bash -c '. "$0"; ql_vocabulary "$1"' "$QUEUE_LIB" "$address")"
  done <<TABLE
$(rows)
TABLE
}

table_out=$(rows)
home_out=$(home)

if [ "$table_out" = "$home_out" ]; then
  printf 'ok    %s\n' "the schema's table and the vocabulary home agree, key by key"
  pass=$((pass + 1))
else
  printf 'FAIL  %s\n      table:\n%s\n      home:\n%s\n' \
    "the schema's table and the vocabulary home agree, key by key" \
    "$(printf '%s\n' "$table_out" | sed 's/^/        /')" \
    "$(printf '%s\n' "$home_out" | sed 's/^/        /')"
  fail=$((fail + 1))
fi

# The table is not empty and not one row: a parser that silently matched
# nothing would agree with an empty home and pass.
count=$(printf '%s\n' "$table_out" | grep -c .)
check "every documented key is read off the table" 0 "12" -- echo "$count"

# And the two free-form keys are read as free-form rather than as a
# vocabulary of one long value — the half of the parse that has no
# runtime signal anywhere else.
check "a shape cell is read as free-form" 0 "^stage_2.commit_types	$" \
  -- bash -c 'printf "%s\n" "$1" | grep "^stage_2.commit_types"' _ "$table_out"

finish
