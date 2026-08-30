#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A pull request may carry several tasks, and the branch name holds one
# id — so the title's leading tags are the authority on the set.
setup_forge
export PR_HEAD_REF="task/0004-two-at-once"
export PR_TITLE="[TASK-0004][TASK-0005] feat(mirror): reconcile in one pass"
forge_issue 22 open "writrun:task,status:ready" "task-0004 — First"
forge_issue 23 open "writrun:task,status:ready" "task-0005 — Second"
check "every task the title tags is reflected" 0 "task-0005 → status:in-review" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the first mirror moves" \
  "PUT repos/o/r/issues/22/labels -f labels[]=writrun:task -f labels[]=status:in-review"
forge_told "the second mirror moves too" \
  "PUT repos/o/r/issues/23/labels -f labels[]=writrun:task -f labels[]=status:in-review"

finish
