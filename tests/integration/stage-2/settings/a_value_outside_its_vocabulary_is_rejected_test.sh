#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A key only an agent reads is still checked for value: an agent reading
# `gherkin` would write titles in a style the project never chose.
setup
settings_file <<'JSON'
{
  "stage": 3,
  "pr_title_style": "gherkin"
}
JSON
check "a style outside the vocabulary is rejected" 1 \
  "pr_title_style 'gherkin' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": "everything",
  "pr_title_style": "conventional"
}
JSON
check "and so is a level outside it" 1 \
  "stage 'everything' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

finish
