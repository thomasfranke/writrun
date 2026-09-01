#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `$(git … || true)` yields the same empty string whether nothing matched
# or nothing ran. This check is a gate, and a gate that passes because git
# failed reports a guarantee it never checked.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all

check "an unreadable range is refused, with git's own words" 3 "failed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" nosuchref...HEAD o/r 9
refute "and never claims it looked and found nothing" "nothing is suspended" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" nosuchref...HEAD o/r 9

finish
