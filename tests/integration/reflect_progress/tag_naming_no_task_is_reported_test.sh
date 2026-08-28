#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A tag naming a task with no mirror is reported and skipped, never a
# crash — a typo in a title must not stop the tasks beside it moving.
setup_forge
export PR_HEAD_REF="task/0004-typo-in-title"
export PR_TITLE="[TASK-9999][TASK-0004] feat(x): a tag with no task"
forge_issue 22 open "writrun:task,status:ready" "task-0004 — Real"
check "the unknown tag is named, not fatal" 0 "No mirrored Issue for task-9999." \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the real task beside it still moves" \
  "PUT repos/o/r/issues/22/labels -f labels[]=writrun:task -f labels[]=status:in-review"

finish
