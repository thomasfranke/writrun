#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Every documented key is present, always, in its documented home — the
# same reason front matter carries null fields rather than omitting them:
# a reader sees the whole configuration without having to know the
# defaults.
setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true
  }
}
JSON
check "a file missing a documented key is rejected" 1 \
  "'stage_2.pr_title_style' is missing" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
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
check "and it is rejected for the top-level key too" 1 "'stage' is missing" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a conduct flag is no more optional than the rest" 1 \
  "'stage_1.credit_ai' is missing" \
  -- bash "$CHECK_SETTINGS"

finish
