#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The title moved; the guard did not. Ownership is the body's "Introduced
# by" line, so a tag-shaped title on another PR's mirror is still named in
# the log and never adopted — a lookup finding it is exactly why the guard
# has to hold.
setup_forge
added_task task-001 "Mine"
forge_issue 12 open "writrun:task,status:pending" "[TASK-001] Someone else's" 99
check "a foreign tag-titled mirror is named, not taken" 0 \
  "id collision; not touching it" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no duplicate issue is created" \
  "POST repos/o/r/issues -f title="
forge_not_told "the foreign mirror is not touched" \
  "repos/o/r/issues/12"

finish
