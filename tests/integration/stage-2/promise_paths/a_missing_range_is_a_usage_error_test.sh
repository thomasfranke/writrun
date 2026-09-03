#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Exit 3, never 1: a caller must never read a mis-wired invocation, or a
# range git could not resolve, as a rule violation.
setup
commit_all

check "no argument is a usage error" 3 "usage: check_promise_paths.sh" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh"
check "an empty argument is a usage error" 3 "usage: check_promise_paths.sh" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" ""
check "a range git cannot read is exit 3" 3 "failed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" no-such-ref...HEAD

finish
