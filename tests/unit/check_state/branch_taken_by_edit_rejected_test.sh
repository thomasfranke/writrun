#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule F — taken_by is the same single writer's: the forge's record,
# never a branch's claim.
setup
task_file task-001 in-progress spec-001 null someone
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 in-progress spec-001 null somebody-else
commit_all
check "a branch editing taken_by is rejected" 1 "edits taken_by" \
  -- bash "$CHECK_STATE" main...HEAD

finish
