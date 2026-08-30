#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The whole point of the file: a value the machinery and the agents both
# read out of one place.
setup
settings_file <<'JSON'
{
  "stage": 2,
  "pr_title_style": "bracketed"
}
JSON
check "a present key prints its value" 0 "2" \
  -- bash "$READ_SETTING" stage
check "and so does the other one" 0 "bracketed" \
  -- bash "$READ_SETTING" pr_title_style

# Edge case: the reader takes everything after the key's colon, so a
# quoted value carrying a colon of its own survives whole.
settings_file <<'JSON'
{
  "stage": 3,
  "pr_title_style": "conventional",
  "label_prefix": "status:"
}
JSON
check "a colon inside a quoted value is not a separator" 0 "status:" \
  -- bash "$READ_SETTING" label_prefix

finish
