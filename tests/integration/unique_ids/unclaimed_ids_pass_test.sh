#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
stub_forge
forge_pr 9 added work/tasks/task-0009-theirs.md
task_file task-0007 ready spec-0007
spec_file spec-0007 task-0007 draft
commit_all
check "ids nobody else claims pass" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
