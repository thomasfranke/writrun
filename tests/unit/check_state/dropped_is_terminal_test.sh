#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule H — dropped is the queue's honest word for "this will not
# happen"; nothing leaves it, and new work is a new task.
setup
task_file task-001 backlog spec-001
spec_file spec-001 task-001 draft
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 dropped spec-001
commit_all
check "backlog -> dropped by hand is accepted" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-001 dropped spec-001
spec_file spec-001 task-001 draft
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 ready spec-001
commit_all
check "dropped -> ready is rejected" 1 "dropped is terminal" \
  -- bash "$CHECK_STATE" main...HEAD

finish
