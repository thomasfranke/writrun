#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A merge whose diff never touched the task file still lands the head
# branch's own task — the caller passes its id from the branch name.
setup
git checkout -q main
task_file task-001 in-progress spec-001 null somebody
spec_file spec-001 task-001 approved
printf 'code\n' > code.txt
commit_all
printf 'more code\n' >> code.txt
commit_all

check "the head task lands although the diff missed it" 0 "in-progress -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD task-001

finish
