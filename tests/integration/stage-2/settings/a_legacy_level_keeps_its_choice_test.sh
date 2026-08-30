#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The rename has a bridge: a settings file still saying `level` keeps
# the choice it made — an adopter who opted all the way out must not
# wake to every workflow on because a key changed names under them.
setup
settings_file <<'JSON'
{
  "level": "tasks-and-specs",
  "pr_title_style": "conventional"
}
JSON
check "the old full opt-out still reads as stage 1" 0 "1" \
  -- bash "$READ_SETTING" stage
check "and still stops the workflows" 0 "stops below 2" \
  -- bash "$STAGE_GATE" 2
check "while the check names the rename" 1 "'level' was renamed" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "level": "pull-requests",
  "pr_title_style": "conventional"
}
JSON
check "the middle level maps to stage 2" 0 "2" \
  -- bash "$READ_SETTING" stage

finish
