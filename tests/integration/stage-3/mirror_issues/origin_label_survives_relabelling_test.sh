#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Unlike `status:`, the origin label is never changed and never removed:
# it is a fact about the task's birth, so it stays on the mirror through
# every state. On the merged path that guarantee is now structural rather
# than restated — the pass writes no label set at all, so there is no
# rewrite for the worn label to fall out of.
setup_forge
added_task task-001 "Checkout returns 500" spec-001 report
added_spec spec-001 task-001 approved
export PR_STATE=closed PR_MERGED=true
forge_issue 12 open "writrun:task,status:proposed,origin:report" "[TASK-001] Checkout returns 500"
check "the merge leaves the label to the projection" 0 \
  "task-001 is in the queue; its label is the projection's" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and rewrites no label set the origin could drop out of" \
  "PUT repos/o/r/issues/12/labels"

finish
