#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule E — the five working states have one writer, and it is the
# machinery on the authority branch, never a branch (statuses.md).
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 in-progress spec-001
commit_all
check "a branch moving ready -> in-progress is rejected" 1 "moves ready -> in-progress on a branch" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-001 in-progress spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 done spec-001
commit_all
check "and in-progress -> done by hand is rejected" 1 "on a branch" \
  -- bash "$CHECK_STATE" main...HEAD

finish
