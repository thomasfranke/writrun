#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The merge writer refuses the claim but not the event: a claim over the
# ceiling drops the carried ids with the refusal printed, while the
# range-derived scope still records — the diff is the repository's own
# evidence, the title only the author's claim — and the exit stays 0,
# because a merged close fires no second event and the Commit step
# behind this is success-gated (spec-0069).
setup
git checkout -q main
task_file task-0001 in-progress "" null worker
task_file task-0003 in-progress "" null worker
for n in 2 4 5 6 7 8 9; do
  task_file "task-000$n" ready ""
done
commit_all
# The range's own evidence: task-0003 declares its completed date.
task_file task-0003 in-progress "" 2026-09-04T00:00:00Z worker
commit_all

export PR_HEAD_REF="task/0001-the-work"
export PR_TITLE="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009][Feat][Ci] Everything at once"

check "the refusal is printed and the exit stays 0" 0 "the ceiling is 8" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD
task_field "the task the range touched is recorded on its evidence" task-0003 status done
task_field "the branch's own task is not landed on the refused claim" task-0001 status in-progress
task_field "its taken_by stands" task-0001 taken_by worker
task_field "a claimed task the range never touched is untouched" task-0005 status ready
unset PR_HEAD_REF PR_TITLE

finish
