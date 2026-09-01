#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The window between a draft pull request opening and the status commit
# landing: the task file still reads `ready` while the forge already shows
# somebody on it. That record is packed on its own path, and it must hold
# the same four fields step 0 packs — one short and the title slides into
# the pause slot, printed as a reason nobody derived.
setup
task_file task-0007 ready spec-0009
spec_file spec-0009 task-0007 approved
export WRITRUN_PR_LIST="$(printf '7\ttask/0007-thing\tdana\tOpen before the status commit landed')"

check "the taken task is named beside its own title" 1 "@dana  *Test task task-0007" \
  -- bash "$LIST_TASKS"
refute "and nothing calls it paused" "paused" -- bash "$LIST_TASKS"

finish
