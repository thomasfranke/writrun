#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The top level is where this repository already was, so shipping the
# mechanism at today's values changes nothing that runs.
setup
settings_file <<'JSON'
{
  "level": "github-issues",
  "pr_title_style": "conventional"
}
JSON
check "writrun check and approve run" 0 "reaches 'pull-requests'" \
  -- bash "$LEVEL_GATE" pull-requests
check "and so do issues and progress" 0 "reaches 'github-issues'" \
  -- bash "$LEVEL_GATE" github-issues

# A level outside the vocabulary is check_settings.sh's fault to name;
# the gate keeps the machinery running rather than stopping it silently.
settings_file <<'JSON'
{
  "level": "everything",
  "pr_title_style": "conventional"
}
JSON
check "an unreadable level does not silently stop the machinery" 0 \
  "reaches 'github-issues'" \
  -- bash "$LEVEL_GATE" github-issues

finish
