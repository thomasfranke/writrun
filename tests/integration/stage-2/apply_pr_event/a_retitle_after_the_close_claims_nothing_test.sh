#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `edited` fires on closed and merged pull requests as readily as on open
# ones. Nothing else in the arm reads the state, so a tag added to the
# title of a pull request that closed last week took the task it named —
# `in-progress` with `taken_by`, on work no pull request is doing. The
# close releases; a retitle after it must not re-claim (spec-0077's
# "the close must win").
setup
task_file task-0001 ready ""
task_file task-0002 ready ""

export PR_HEAD_REF="task/0001-the-work" PR_AUTHOR=worker PR_DRAFT=true
export GH_TOKEN="" GH_REPO="o/r"
export PR_TITLE_FROM="[TASK-0001] The work"
export PR_TITLE="[TASK-0001][TASK-0002] The work, and its sibling"

export PR_MERGED=false PR_STATE=closed
check "a retitle on a closed pull request records nothing" 0 "the pull request is closed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "the released task stayed released" task-0001 status ready
task_field "and the newly named one was never taken" task-0002 status ready
task_field "nor stamped with an author" task-0002 taken_by null

# A merged pull request is the same answer by the other field: the merge
# recording owns what it landed, and a title edit after it claims nothing.
export PR_MERGED=true PR_STATE=closed
check "a retitle on a merged pull request records nothing" 0 "the pull request is closed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "the merged task stayed put" task-0002 status ready

# The guard is state, not the event: an open pull request still records.
export PR_MERGED=false PR_STATE=open
check "an open pull request still re-records" 0 "ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "the newly claimed task is in flight" task-0002 status in-progress

unset PR_HEAD_REF PR_TITLE PR_TITLE_FROM PR_AUTHOR PR_DRAFT PR_MERGED PR_STATE GH_TOKEN GH_REPO

finish
