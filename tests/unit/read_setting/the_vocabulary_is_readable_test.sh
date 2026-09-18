#!/usr/bin/env bash
# --vocabulary is how a reader offers the choice before the write: a
# closed key's values, one per line, from the one home check_settings.sh
# judges by (decision 0079). A free-form key and an undocumented address
# both answer nothing, which is the one grammar a caller has to read.
. "$(dirname "$0")/../../pipeline_lib.sh"

# The vocabulary is the key's, not the file's — so the answer is the same
# with a file, with a different file, and with none at all.
setup

check "a sectioned closed key prints its values, one per line" 0 \
  "$(printf 'conventional\nbracketed')" \
  -- bash "$READ_SETTING" stage_2.pr_title_style --vocabulary
check "the top-level key prints the numbers the file accepts" 0 \
  "$(printf '1\n2\n3')" -- bash "$READ_SETTING" stage --vocabulary
check "a boolean is a vocabulary, so a toggle renders from the same call" 0 \
  "$(printf 'true\nfalse')" -- bash "$READ_SETTING" stage_2.auto_push --vocabulary
check "a stage_1 declaration answers too" 0 \
  "$(printf 'always\nwhen-warranted')" \
  -- bash "$READ_SETTING" stage_1.spec_required --vocabulary

# Free-form: a shape is not a list, so there is nothing to print and the
# run is still a success — the reader reads, it never judges.
exact() {   # exact <name> <want> -- <cmd...> — the whole of stdout
  local name="$1" want="$2"; shift 3
  local out
  out=$("$@")
  if [ "$out" = "$want" ]; then
    printf 'ok    %s\n' "$name"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected: [%s]\n      got:      [%s]\n' \
      "$name" "$want" "$out"
    fail=$((fail + 1))
  fi
}

exact "a free-form key answers nothing at all" "" \
  -- bash "$READ_SETTING" stage_2.commit_types --vocabulary
exact "and so does its sibling" "" \
  -- bash "$READ_SETTING" stage_2.commit_scopes --vocabulary
exact "an address the schema does not document answers nothing" "" \
  -- bash "$READ_SETTING" stage_2.invented --vocabulary
check "and answering nothing is still exit 0" 0 "" \
  -- bash "$READ_SETTING" stage_2.commit_types --vocabulary

# A declared value does not narrow the vocabulary: what the project chose
# and what the key accepts are different questions.
settings_file <<'JSON'
{
  "stage": 1,
  "stage_2": {
    "pr_title_style": "bracketed"
  }
}
JSON
check "a declared choice leaves the vocabulary whole" 0 \
  "$(printf 'conventional\nbracketed')" \
  -- bash "$READ_SETTING" stage_2.pr_title_style --vocabulary

# The two flags ask different questions about different things — a
# value's origin, a key's values — so both at once is a usage error and
# not a guess at which was meant.
check "both flags at once is a usage error" 3 "usage" \
  -- bash "$READ_SETTING" stage --origin --vocabulary
check "in either order" 3 "usage" \
  -- bash "$READ_SETTING" stage --vocabulary --origin
check "the usage line names both flags" 3 "vocabulary" \
  -- bash "$READ_SETTING" stage --origin --vocabulary

finish
