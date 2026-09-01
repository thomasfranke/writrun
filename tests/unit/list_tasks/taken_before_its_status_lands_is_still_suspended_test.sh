#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The same window, amended: an amendment does not wait for the status
# commit either, so the pause is derived on this path exactly as it is on
# the one the recorded status reaches.
setup
task_file task-0007 ready spec-0009
task_file task-0008 in-progress spec-0010 "" erin
spec_file spec-0009 task-0007 approved
spec_file spec-0010 task-0008 approved
export WRITRUN_PR_LIST="$(printf '7\ttask/0007-thing\tdana\tthe work\n8\ttask/0008-other\terin\tthe other work\n9\tqueue/amend-the-promise\tdana\tAmend the promise')"
export WRITRUN_PR_FILES="$(printf '9\twork/specs/spec-0009.md')"

check "the pause is named on the taken-but-not-yet-recorded path too" 1 \
  "spec-0009 is amended by #9" -- bash "$LIST_TASKS"

finish
