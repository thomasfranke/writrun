#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Ownership decides whether this PR may touch a mirror, and a live pull
# request's mirror is the case that has not changed: #99 is still open,
# so somebody is behind it and the collision is named, never adopted.
setup_forge
added_task task-001 "Mine"
forge_issue 12 open "writrun:task,status:backlog" "task-001 — Someone else's" 99
forge_pr_state 99 open
check "a foreign mirror with the same id is named" 0 \
  "mirrored by #99, which is still open" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no duplicate issue is created" \
  "POST repos/o/r/issues -f title="
forge_not_told "the foreign mirror is not touched" \
  "repos/o/r/issues/12"

finish
