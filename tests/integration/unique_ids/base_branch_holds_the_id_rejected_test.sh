#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The id is already an id: it sits on the branch this change targets, so
# whoever put it there holds it and this change renumbers.
setup
stub_forge
task_file task-0007 pending ""
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
cp work/tasks/task-0007.md work/tasks/task-0007-again.md
commit_all
check "an id the base branch already holds is rejected" 1 "task-0007-again" \
  -- bash "$CI_SCRIPTS/pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
