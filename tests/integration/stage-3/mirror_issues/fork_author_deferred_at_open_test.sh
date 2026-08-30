#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Mirrors defer to authority: an author the forge does not recognize gets
# the mirror at merge, when the queue really gains the task — deferred,
# never denied, and a drive-by PR cannot spray Issues.
setup_forge
export PR_AUTHOR_ASSOCIATION=NONE
added_task task-001 "From a fork"
check "an unrecognized author defers the mirror" 0 \
  "task-001: author lacks authority — mirror deferred to merge." \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no issue is created at open" \
  "POST repos/o/r/issues -f title="

finish
