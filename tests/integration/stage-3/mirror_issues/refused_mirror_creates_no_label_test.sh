#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Creating a label in the repository is a write like any other. The paths
# that decide to touch nothing must touch nothing at all — otherwise a
# run that logs "not touching it" leaves an `origin:` label behind in a
# repository where no mirror wears it.
setup_forge
added_task task-001 "Checkout returns 500" "" report
forge_issue 12 open "writrun:task,status:proposed" "[TASK-001] Checkout returns 500" 99
forge_pr_state 99 open
check "a mirror owned by a live pull request is refused" 0 \
  "is mirrored by #99, which is still open" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and no origin label is declared on the way past" \
  "POST repos/o/r/labels -f name=origin:report"

# Closed without merging: the queue never gained the task, so no label
# it would have worn is owed either.
setup_forge
added_task task-001 "Checkout returns 500" "" report
export PR_STATE=closed PR_MERGED=false
forge_issue 12 open "writrun:task,status:proposed" "[TASK-001] Checkout returns 500"
check "a pull request closed unmerged retires its mirror" 0 \
  "task-001 closed — #7 was not merged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "without declaring an origin label nothing will wear" \
  "POST repos/o/r/labels -f name=origin:report"

finish
