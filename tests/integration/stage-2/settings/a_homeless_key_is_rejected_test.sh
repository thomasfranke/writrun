#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The address is a key's identity, so a documented key in the wrong
# section is not merely misplaced — the reader looking in its documented
# home finds nothing and falls back to the default, silently. That is the
# failure this names.
setup

settings_file <<'JSON'
{
  "stage": 3,
  "pr_title_style": "bracketed",
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true
  }
}
JSON
check "a key left at the top level is homeless" 1 \
  "its home is stage_2" \
  -- bash "$CHECK_SETTINGS"
check "and it is reported missing from the home it belongs in" 1 \
  "'stage_2.pr_title_style' is missing" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "auto_pr": true,
    "credit_ai": true
  },
  "stage_2": {
    "pr_title_style": "conventional"
  }
}
JSON
check "a key in the wrong section is homeless the same way" 1 \
  "'auto_pr' sits at line" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage_1": {
    "stage": 3,
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so is the top-level key pushed into a section" 1 \
  "its home is the top level" \
  -- bash "$CHECK_SETTINGS"

finish
