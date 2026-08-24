#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A quoted `status: completed` line added to a task's body is prose, not
# a completion — rule C fires only when the front matter reaches
# completed, and this task's still says in-progress.
setup
task_file task-001 in-progress spec-001
spec_file spec-001 task-001 draft
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'status: completed\n' >> work/tasks/task-001.md
commit_all
check "a quoted completion in a body is not a completion" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish
