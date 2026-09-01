#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Exit 1 is this check's "a promise is incomplete". A caller that never
# passed a range has a wiring bug, and a wiring bug reported in the code
# reserved for rule violations sends whoever reads it to the spec instead
# of to the workflow.
setup

check "no range at all is a usage error, not a rejection" 3 "usage:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh"
check "and an empty one is the same" 3 "usage:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" ""

finish
