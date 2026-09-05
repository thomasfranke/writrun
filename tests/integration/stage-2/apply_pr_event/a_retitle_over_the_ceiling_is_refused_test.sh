#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A title edit expands flight, so it is claiming however it is spelled,
# and above the ceiling it is refused exactly as an `opened` claim is —
# whole, with nothing written. Decision 0069 exempts releasing, not this
# (spec-0077).
setup
task_file task-0001 in-progress "" null worker
task_file task-0009 ready ""

export PR_HEAD_REF="task/0001-the-work" PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export GH_TOKEN="" GH_REPO="o/r"
export PR_TITLE_FROM="[TASK-0001] The work"
export PR_TITLE="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009] Everything"

check "a retitle over the ceiling is refused whole" 1 "Nothing was recorded" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "and not one task moved" task-0009 status ready

# A refused claim wrote nothing, so nothing it named is in flight by way
# of it. Editing back under the ceiling must therefore record the whole
# new set — reading the refused title as a claim would leave the ceiling's
# own heal path recording nothing at all.
export PR_TITLE_FROM="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009] Everything"
export PR_TITLE="[TASK-0001][TASK-0009] What the work carries"
check "editing back under the ceiling records the set" 0 "ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "the task the refused title named is now in flight" task-0009 status in-progress

unset PR_HEAD_REF PR_TITLE PR_TITLE_FROM PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
