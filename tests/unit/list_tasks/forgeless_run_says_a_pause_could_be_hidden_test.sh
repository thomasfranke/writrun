#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The degrade contract: with no forge answer the lister reports files-only
# truth and says so. Silence here would read as "nobody is suspended",
# which is the one thing it cannot know.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
export WRITRUN_PR_LIST=""
check "a forgeless run says an open amendment would not have been seen" 1 \
  "amendment suspending a task" -- bash "$LIST_TASKS"

finish
