#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The status vocabulary is closed — "these values and no others". An
# invented one would fall through every filter as if held back forever.
setup
task_file task-001 done ""
check "an invented status is named" 1 "not a task status" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
