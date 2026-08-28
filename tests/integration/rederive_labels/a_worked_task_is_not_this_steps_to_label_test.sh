#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# An amendment re-approved by a merge says nothing about who is working
# the task. `in-progress` and what follows belong to reflect_progress.sh,
# which knows whether a pull request is open — the queue does not.
# Overwriting from here would tell a worker's mirror it is free again.
setup_forge
base_task task-0005 in-progress spec-0003
base_spec spec-0003 task-0005 approved
forge_issue 31 open "writrun:task,status:in-progress" "[TASK-0005] Being worked"
check "a task under way is left alone" 0 "not this step's to write" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md
forge_not_told "its label is untouched" \
  "PUT repos/o/r/issues/31/labels"

finish
