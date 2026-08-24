#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
export WRITRUN_PR_LIST=""
check "no PR data warns instead of implying nobody is working" 0 "could not reach GitHub" \
  -- bash "$LIST_TASKS"

finish
