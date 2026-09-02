#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Half the union, and the only half Stage 1 has: an amendment that has
# already landed leaves the spec back in `draft` on this checkout, and the
# task riding an open pull request cannot advance against it. No forge is
# consulted for this — reading the files is the whole answer.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 draft
export WRITRUN_PR_LIST="$(printf '7\ttask/0007-thing\tdana')"
check "a spec back in draft here suspends the task in flight" 1 \
  "paused — spec-0009 is draft here" -- bash "$LIST_TASKS"

finish
