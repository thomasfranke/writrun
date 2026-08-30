#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
export WRITRUN_PR_LIST="$(printf '7\tspec/002-other\teli')"
check "an unrelated open PR leaves the task available" 0 "task-001" -- bash "$LIST_TASKS"

finish
