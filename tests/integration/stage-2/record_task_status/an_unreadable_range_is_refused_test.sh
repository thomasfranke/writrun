#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# An unreadable range is not an empty one — the same honesty every other
# range reader here holds (spec-0013).
setup
task_file task-001 ready ""
commit_all
check "an unreadable range is refused, with git's own words" 3 "failed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" nosuchref...HEAD

finish
