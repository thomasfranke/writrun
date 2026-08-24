#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A blocked task states its own unblock condition — blocked with a null
# reason is a task nobody can ever bring back.
setup
task_file task-001 blocked ""
check "blocked without a reason is named" 1 "blocked_reason is null" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
