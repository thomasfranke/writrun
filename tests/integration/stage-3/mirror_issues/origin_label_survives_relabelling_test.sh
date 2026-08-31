#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Unlike `status:`, the origin label is never changed and never removed:
# it is a fact about the task's birth, so it stays on the mirror through
# every state. Each rewrite below replaces the whole label set, so each
# one has to re-state it.
setup_forge
added_task task-001 "Checkout returns 500" spec-001 report
added_spec spec-001 task-001 approved
export PR_STATE=closed PR_MERGED=true
forge_issue 12 open "writrun:task,status:proposed,origin:report" "[TASK-001] Checkout returns 500"
check "the merge moves the mirror to ready" 0 "task-001 is ready for development" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and carries the origin label through the move" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=status:ready -f labels[]=origin:report"

finish
