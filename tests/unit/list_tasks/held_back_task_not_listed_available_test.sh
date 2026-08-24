#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
check "a held-back task is not listed as available" 1 "Nothing is available" \
  -- bash "$LIST_TASKS"

finish
