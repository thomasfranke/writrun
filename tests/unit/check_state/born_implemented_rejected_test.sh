#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule D: an added file has no removed lines for rules A and B to read, so
# without this rule a spec could enter the tree past both gates unseen.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 implemented
commit_all
check "a spec born implemented is rejected" 1 "already 'implemented'" \
  -- bash "$CHECK_STATE" main...HEAD

finish
