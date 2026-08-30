#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The diff that implements a task's last spec writes the completed date,
# or no merge can ever move the task to done.
setup
task_file task-001 in-progress spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 implemented
commit_all
check "implementing the last spec without the date is rejected" 1 "leaves its completed date null" \
  -- bash "$CHECK_STATE" main...HEAD

finish
