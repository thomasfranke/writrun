#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The other close path: a pull request dies unmerged and its mirrors are
# retired. Same rule — a label naming a place inside the pipeline is false
# on an issue that has left it.
setup_forge
export PR_STATE=closed PR_MERGED=false
added_task task-001 "Never landed"
forge_issue 12 open "writrun:task,status:proposed" "[TASK-001] Never landed"
check "a dead PR retires its mirrors" 0 "task-001 closed — #7 was not merged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the status label is stripped first" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task"
forge_not_told "no status label survives the retirement" \
  "-f labels[]=status:"
forge_told "the mirror closes as not planned" \
  "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=not_planned"

finish
