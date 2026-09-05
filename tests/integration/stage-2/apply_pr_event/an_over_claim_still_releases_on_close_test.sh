#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The ceiling bounds claiming, not releasing. A pull request records its
# task under a one-tag title, the title is later edited over the ceiling
# — no `edited` trigger is wired, so nothing re-records — and the pull
# request is closed unmerged. Refusing the close too would leave the task
# `in-progress` with `taken_by` naming a closed pull request, and no
# later event of that pull request can free it: the "stranded in-flight
# with no PR heals never" state this script's own header forbids
# (spec-0069).
setup
task_file task-0001 in-progress "" null worker

export PR_HEAD_REF="task/0001-the-work" PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export GH_TOKEN="" GH_REPO="o/r"
export PR_TITLE="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009] retitled after the recording"

check "a close over the ceiling still releases the task" 0 "in-progress -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "the task left flight" task-0001 status ready
task_field "and taken_by is cleared" task-0001 taken_by null

# Reset and read the message: green, and it still says what was claimed.
task_file task-0001 in-progress "" null worker
check "and says the claim was over the ceiling" 0 "the ceiling is 8" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed

# The exemption is the close's alone — every event that expands flight
# still refuses the same claim whole.
task_file task-0001 ready ""
check "an event that expands flight is still refused" 1 "Nothing was recorded" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
task_field "and nothing moved" task-0001 status ready

unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
