#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Nothing amends this task's spec, so the In-flight section says exactly
# what it said before the pause existed.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
export WRITRUN_PR_LIST="$(printf '7\ttask/0007-thing\tdana\n9\tdocs/some-rule\tdana')"
export WRITRUN_PR_FILES="$(printf '9\tdocs/product/chapter.md')"
check "the task is still reported in flight" 1 "#7 by @dana" -- bash "$LIST_TASKS"
refute "and nothing calls it paused" "paused" -- bash "$LIST_TASKS"

finish
