#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Identity is the id, and the file is found by it — an id disagreeing
# with its filename breaks every resolution silently.
setup
task_file task-001 pending ""
mv work/tasks/task-001.md work/tasks/task-002.md
check "an id disagreeing with its filename is named" 1 "is not the filename's id" \
  -- bash "$CHECK_FRONT_MATTER"

finish
