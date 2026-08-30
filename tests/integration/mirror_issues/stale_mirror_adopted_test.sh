#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The case the refusal handled badly. #99 introduced this mirror and is
# gone — closed unmerged, or merged without the task. Nobody is behind
# the ownership line, so refusing to touch it leaves the task with no
# mirror at all and nothing ever creates one.
setup_forge
added_task task-001 "Mine now"
forge_issue 12 open "writrun:task,status:backlog" "task-001 — Left behind" 99
forge_pr_state 99 closed
check "a mirror whose owner is gone is adopted" 0 \
  "adopted stale mirror #12" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the ownership line becomes this PR's" \
  "PATCH repos/o/r/issues/12 -f body="
forge_told "and it names #7" "| Introduced by | #7 |"
forge_not_told "no second mirror is created for the same task" \
  "POST repos/o/r/issues -f title="
forge_told "the labels are re-derived, not inherited" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=status:proposed"

# A number the forge does not know is not open either — nothing can be
# working behind a pull request that does not exist.
setup_forge
added_task task-001 "Mine now"
forge_issue 12 open "writrun:task,status:backlog" "task-001 — Left behind" 404
check "an owner the forge cannot find is stale too" 0 \
  "adopted stale mirror #12" \
  -- bash "$MIRROR_ISSUES" o/r 7

finish
