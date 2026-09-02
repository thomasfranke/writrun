#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 done spec-001 2026-08-22
spec_file spec-001 task-001 implemented
check "a completed task is not reported as held back" 1 "Nothing is available" \
  -- bash "$LIST_TASKS"

finish
