#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The other half, and the one the files can never show: while the
# amendment is still open, this checkout shows the spec exactly as it was
# approved. The pause is visible only in the open pull requests, and it is
# named beside the number that caused it.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
export WRITRUN_PR_LIST="$(printf '7\ttask/0007-thing\tdana\n9\tqueue/amend-the-promise\tdana')"
export WRITRUN_PR_FILES="$(printf '9\twork/specs/spec-0009-thing.md')"
check "an open amendment suspends the task, beside its number" 1 \
  "spec-0009 is amended by #9" -- bash "$LIST_TASKS"

finish
