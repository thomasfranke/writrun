#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# An over-ceiling old title is read as claiming nothing, which is right
# about events under *that* title and says nothing about earlier ones.
# The sequence that separates the two: open at one tag, a review requests
# changes, retitle to nine (refused, nothing written), retitle back. The
# refused title arrives as `PR_TITLE_FROM`, so the first task reads as
# newly added — and `take` would knock it out of the state the review
# gave it, which is the one move this arm forbids (spec-0077).
setup
task_file task-0001 in-progress "" null worker
task_file task-0009 ready ""

export PR_HEAD_REF="task/0001-the-work" PR_AUTHOR=worker PR_DRAFT=false
export PR_MERGED=false PR_STATE=open
export GH_TOKEN="" GH_REPO="o/r"
export PR_TITLE_FROM="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009] Everything"
export PR_TITLE="[TASK-0001][TASK-0009] What the work carries"

check "the edit back under the ceiling records the task in rest" 0 "ready -> in-review" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "the refused title's resting task is now in flight" task-0009 status in-review
task_field "the changes-requested task kept its status" task-0001 status in-progress
task_field "and its author" task-0001 taken_by worker

# In flight under someone else is not this pull request's own recording.
# Two pull requests on one task is `take`'s newest-wins edge, and a
# retitle reaches it like any other claiming event.
task_file task-0007 in-review "" null other
export PR_TITLE_FROM="[TASK-0001] The work"
export PR_TITLE="[TASK-0001][TASK-0007] The work, and another's"
check "a task in flight under another author is still taken" 0 "moved" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "taken_by follows the newest pull request" task-0007 taken_by worker

# When the in-flight check is what emptied the set, the line says so:
# a reader deciding whether a recording went missing is reading it.
task_file task-0003 in-review "" null worker
export PR_TITLE_FROM="[TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009][TASK-0010][TASK-0011] Everything"
export PR_TITLE="[TASK-0003] Under review"
export PR_HEAD_REF="task/0003-the-work"
check "nothing recorded, and the line names the reason" 0 "no task not already in flight" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "the in-review task kept its status" task-0003 status in-review

unset PR_HEAD_REF PR_TITLE PR_TITLE_FROM PR_AUTHOR PR_DRAFT PR_MERGED PR_STATE GH_TOKEN GH_REPO

finish
