#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule G — blocked pairs with backlog/ready only. An in-flight task's
# blocker is visible on its pull request, and the status table draws no
# such edge.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 blocked spec-001
sed -i.bak 's/^blocked_reason: null$/blocked_reason: waiting on upstream/' work/tasks/task-001.md && rm -f work/tasks/*.bak
commit_all
check "ready -> blocked by hand is accepted" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-001 in-progress spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 blocked spec-001
sed -i.bak 's/^blocked_reason: null$/blocked_reason: waiting on upstream/' work/tasks/task-001.md && rm -f work/tasks/*.bak
commit_all
check "in-progress -> blocked is rejected" 1 "blocked is reachable from backlog or ready only" \
  -- bash "$CHECK_STATE" main...HEAD

finish
