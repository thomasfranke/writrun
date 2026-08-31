#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A key only an agent reads is still checked for value: an agent reading
# `gherkin` would write titles in a style the project never chose.
setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "gherkin"
  }
}
JSON
check "a style outside the vocabulary is rejected" 1 \
  "pr_title_style 'gherkin' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": "everything",
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so is a stage outside it" 1 \
  "stage 'everything' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

# The three conduct flags are booleans, and "ask" is not one of them: an
# agent reading anything else would have to guess which side it means.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": "ask",
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "auto_commit takes true or false and nothing else" 1 \
  "auto_commit 'ask' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": 1,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so does auto_pr" 1 "auto_pr '1' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": "no"
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so does credit_ai" 1 "credit_ai 'no' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

finish
