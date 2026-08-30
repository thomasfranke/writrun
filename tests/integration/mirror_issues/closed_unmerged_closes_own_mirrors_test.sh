#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The PR dies unmerged: the queue never gained its tasks, so every mirror
# it introduced closes as not planned — reopening the PR restores them.
setup_forge
export PR_STATE=closed PR_MERGED=false
added_task task-001 "Never landed"
forge_issue 12 open "writrun:task,status:backlog" "task-001 — Never landed"
check "a dead PR retires its mirrors" 0 "task-001 closed — #7 was not merged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror closes as not planned" \
  "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=not_planned"

finish
