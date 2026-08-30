#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
export WRITRUN_PR_LIST="$(printf '9\ttask/001-thing\tdana')"
check "a task-named branch is matched too" 1 "In flight" -- bash "$LIST_TASKS"

finish
