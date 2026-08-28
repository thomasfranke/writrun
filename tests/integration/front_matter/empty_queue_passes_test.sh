#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Nothing to validate is a clean result, not an error — an adopter's
# queue starts empty on purpose.
setup
check "an empty queue is canonical" 0 "0 queue file(s)" \
  -- bash "$CHECK_FRONT_MATTER"

finish
