#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
commit_all
check "a change outside docs/ owes no declaration" 0 "nothing to declare" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
