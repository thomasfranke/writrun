#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Passing on a narrower scan than the rule describes is exactly how the
# collision this check exists for got merged. It passes, and it says what
# it could not see.
setup
stub_forge
forge_unavailable
task_file task-0007 ready ""
commit_all
check "a clean pass without the forge reports its narrow view" 0 "did not answer" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
