#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The whole point of the file: a value the machinery and the agents both
# read out of one place. The address, not the name, is what identifies a
# key — bare at the top level, through its section below it.
setup
settings_file <<'JSON'
{
  "stage": 2,
  "stage_1": {
    "auto_commit": false,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "bracketed"
  }
}
JSON
check "a top-level key prints its value, addressed bare" 0 "2" \
  -- bash "$READ_SETTING" stage
check "a sectioned key prints its value, addressed through its section" 0 \
  "bracketed" \
  -- bash "$READ_SETTING" stage_2.pr_title_style
check "and so does one in the other section" 0 "false" \
  -- bash "$READ_SETTING" stage_1.auto_commit
check "and the rest of stage_1" 0 "true" \
  -- bash "$READ_SETTING" stage_1.credit_ai
check "and the rest of stage_2" 0 "true" \
  -- bash "$READ_SETTING" stage_2.auto_pr

# Edge case: the reader takes everything after the key's colon, so a
# quoted value carrying a colon of its own survives whole — and a brace
# or a dot inside one is never read as structure, because the section
# state machine reads line shapes and never value content.
settings_file <<'JSON'
{
  "stage": 3,
  "label_prefix": "status:",
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional",
    "opener": "{"
  }
}
JSON
check "a colon inside a quoted value is not a separator" 0 "status:" \
  -- bash "$READ_SETTING" label_prefix
check "a brace inside a quoted value does not open a section" 0 \
  "conventional" \
  -- bash "$READ_SETTING" stage_2.pr_title_style

# The same name in two sections is two keys; a name is not identity.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true,
    "note": "one"
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional",
    "note": "two"
  }
}
JSON
check "the same name in one section" 0 "one" -- bash "$READ_SETTING" stage_1.note
check "is not the same key as in the other" 0 "two" \
  -- bash "$READ_SETTING" stage_2.note

finish
