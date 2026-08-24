#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# Ownership decides whether this PR may touch a mirror: an id collision
# with another PR's mirror is named in the log, never adopted.
setup_forge
added_task task-001 "Mine"
forge_issue 12 open "writrun:task,status:pending" "task-001 — Someone else's" 99
check "a foreign mirror with the same id is named" 0 \
  "id collision; not touching it" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no duplicate issue is created" \
  "POST repos/o/r/issues -f title="
forge_not_told "the foreign mirror is not touched" \
  "repos/o/r/issues/12"

finish
