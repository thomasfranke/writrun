#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `edited` fires on body and base changes too, and neither carries a
# claim. The forge sets `changes.title.from` only when the title moved,
# so an empty one is the whole test — no file read, no forge call
# (spec-0077).
setup
task_file task-0001 ready ""

export PR_HEAD_REF="task/0001-the-work" PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export GH_TOKEN="" GH_REPO="o/r"
export PR_TITLE="[TASK-0001] The work"
export PR_TITLE_FROM=""

check "a body-only edit stands down" 0 "the title did not change" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" edited
task_field "and the task never left rest" task-0001 status ready
task_field "nor was it taken" task-0001 taken_by null

unset PR_HEAD_REF PR_TITLE PR_TITLE_FROM PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
