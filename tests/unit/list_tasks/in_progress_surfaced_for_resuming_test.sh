#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 in-progress ""
check "an in-progress task is surfaced for resuming" 1 "In progress" -- bash "$LIST_TASKS"

finish
