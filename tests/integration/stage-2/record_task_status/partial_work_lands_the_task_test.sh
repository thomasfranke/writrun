#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# One spec of several is work taken, not finished: the merge lands the
# task back where its specs put it, and clears taken_by.
setup
git checkout -q main
task_file task-001 in-progress "spec-001, spec-002" null somebody
spec_file spec-001 task-001 approved
spec_file spec-002 task-001 approved
commit_all
spec_file spec-001 task-001 implemented
commit_all

check "a partial merge lands the task on ready" 0 "in-progress -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD
grep -qx "taken_by: null" work/tasks/task-001.md \
  && { echo "ok    and clears taken_by"; pass=$((pass+1)); } \
  || { echo "FAIL  and clears taken_by"; fail=$((fail+1)); }

finish
