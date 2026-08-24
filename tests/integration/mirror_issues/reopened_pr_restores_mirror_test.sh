#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A reopened PR finds its mirrors closed as orphans; they are not orphans
# any more.
setup_forge
added_task task-001 "Back again"
forge_issue 12 closed "writrun:task,status:pending" "task-001 — Back again"
check "a reopened PR restores its mirror" 0 "task-001 reopened with #7" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror is reopened" \
  "PATCH repos/o/r/issues/12 -f state=open"
forge_told "and reset to pending" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=status:pending"

finish
