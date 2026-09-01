#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `$(git … || true)` yields the same empty string whether nothing matched
# or nothing ran. This check is a gate, and a gate that passes because git
# failed reports a guarantee it never checked.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md
commit_all

check "an unreadable range is refused, with git's own words" 3 "failed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" nosuchref...HEAD
refute "and never claims it looked and found nothing" "nothing to judge" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" nosuchref...HEAD

finish
