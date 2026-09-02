#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A task's own pull request touches its own spec at the end of every
# implementation — the Outcome section and `status: implemented`. Reading
# that as an amendment would report every finished task as suspended by
# itself, so only pull requests carrying no task id are read.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
export WRITRUN_PR_LIST="$(printf '7\ttask/0007-thing\tdana')"
export WRITRUN_PR_FILES="$(printf '7\twork/specs/spec-0009.md')"
refute "a task's own pull request never suspends it" "paused" -- bash "$LIST_TASKS"

finish
