#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# One merge can complete a task and approve its specs at once. Closing
# wins: every label names a place inside the pipeline, and a closed mirror
# is out of it.
setup_forge
base_task task-0005 ready spec-0003
base_spec spec-0003 task-0005 approved
forge_issue 31 closed "writrun:task" "[TASK-0005] Already closed"
check "a closed mirror is not relabelled" 0 "is closed — no label is written" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md
forge_not_told "nothing is written to it" \
  "PUT repos/o/r/issues/31/labels"

finish
