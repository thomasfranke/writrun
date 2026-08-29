#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The lowest level is a complete adoption: the docs, the queue, the
# schemas and the four gates are all satisfiable with files alone. What
# stops is the mechanical enforcement — and it stops by the setting, not
# by deleting the files, which is the reversal 0041 called for.
setup
settings_file <<'JSON'
{
  "level": "tasks-and-specs",
  "pr_title_style": "conventional"
}
JSON
check "writrun check and approve do not run" 0 "stops below 'pull-requests'" \
  -- bash "$LEVEL_GATE" pull-requests
check "writrun issues and progress do not run" 0 "stops below 'github-issues'" \
  -- bash "$LEVEL_GATE" github-issues
check "and it says the choice is why, not a failure" 0 \
  "not because anything failed" \
  -- bash "$LEVEL_GATE" github-issues

finish
