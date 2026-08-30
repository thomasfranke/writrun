#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The middle level buys mechanical enforcement of the pipeline and stops
# short of the projection: `github-issues` without `pull-requests` would
# ask for a mirror that pull-request events drive, so the levels are one
# ordered value and not two switches.
setup
settings_file <<'JSON'
{
  "stage": 2,
  "pr_title_style": "conventional"
}
JSON
check "writrun check and approve run" 0 "reaches 2" \
  -- bash "$STAGE_GATE" 2
check "the two mirror workflows do not" 0 "stops below 3" \
  -- bash "$STAGE_GATE" 3

finish
