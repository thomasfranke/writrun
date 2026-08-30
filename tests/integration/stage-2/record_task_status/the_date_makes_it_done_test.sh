#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The merge carrying the worker's completed date is what moves a task to
# done — and taken_by stays, as the record of who completed it.
setup
git checkout -q main
task_file task-001 in-progress spec-001 null somebody
spec_file spec-001 task-001 approved
commit_all
sed -i.bak 's/^completed: null$/completed: 2026-08-30T10:00:00Z/' work/tasks/task-001.md && rm -f work/tasks/*.bak
spec_file spec-001 task-001 implemented
commit_all

check "a merge carrying the date moves the task to done" 0 "in-progress -> done" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD
grep -qx "taken_by: somebody" work/tasks/task-001.md \
  && { echo "ok    taken_by stays — who completed it"; pass=$((pass+1)); } \
  || { echo "FAIL  taken_by stays — who completed it"; fail=$((fail+1)); }

finish
