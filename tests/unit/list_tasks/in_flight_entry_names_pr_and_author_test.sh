#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
export WRITRUN_PR_LIST="$(printf '7\tspec/001-thing\tdana')"
check "the in-flight entry names the PR and its author" 1 "#7 by @dana" -- bash "$LIST_TASKS"

finish
