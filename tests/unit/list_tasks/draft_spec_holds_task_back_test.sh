#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 draft
check "a draft spec holds the task back" 1 "spec-001 is draft" -- bash "$LIST_TASKS"

finish
