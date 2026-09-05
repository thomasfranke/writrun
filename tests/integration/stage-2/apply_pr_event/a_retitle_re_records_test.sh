#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The title is one of the two routes into the carried set, and it is the
# author's to rewrite after the recording. Until `edited` was wired, a
# pull request recorded under one tag and retitled to two left the second
# task resting with no event ever reading the new title — and the close
# could not release what was never taken (spec-0077; decision 0069).
setup
task_file task-0001 in-progress "" null worker
task_file task-0002 ready ""

export PR_HEAD_REF="task/0001-the-work" PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export GH_TOKEN="" GH_REPO="o/r"
export PR_TITLE_FROM="[TASK-0001] The work"
export PR_TITLE="[TASK-0001][TASK-0002] The work, and its sibling"

check "the retitle records the task the old title did not claim" 0 "ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "the newly claimed task is in flight" task-0002 status in-progress
task_field "taken by the pull request's author" task-0002 taken_by worker

# Re-recording adds; it never moves a task the old title already claimed.
# `take` against an in-review task would knock it back to in-progress,
# and a title edit is not a review event.
task_file task-0003 in-review "" null worker
export PR_TITLE_FROM="[TASK-0003] Under review"
export PR_TITLE="[TASK-0003] Under review, renamed"
check "a retitle that claims nothing new writes nothing" 0 "claims no task the old title did not" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "and the in-review task kept its status" task-0003 status in-review

unset PR_HEAD_REF PR_TITLE PR_TITLE_FROM PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
