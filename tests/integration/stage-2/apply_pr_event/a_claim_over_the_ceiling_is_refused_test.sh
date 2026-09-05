#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A pull request claiming more than QL_CARRIED_MAX distinct tasks is
# refused whole: nothing is written — a partial write riding a green run
# is the failure the exit contract exists to prevent — the run goes red
# on the author's own pull request, and the message names the count, the
# ceiling, and the heal (spec-0069).
setup
task_file task-0001 ready ""
task_file task-0005 ready ""
task_file task-0009 ready ""

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="task/0001-the-work"
export PR_TITLE="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009][Feat][Ci] Everything at once"

check "nine distinct tasks are refused whole" 1 "claim 9 distinct tasks" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
task_field "the branch's own task did not move" task-0001 status ready
task_field "nor a task the title claimed" task-0005 status ready
task_field "nor the ninth" task-0009 status ready

check "the message names the ceiling" 1 "the ceiling is 8" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
check "and the heal — close and reopen" 1 "close and reopen" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED

finish
