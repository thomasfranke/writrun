#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The other half of the deferral: at merge the queue really gains the
# task, so the catch-up creation runs — and with every spec vouched for,
# the mirror is born ready.
setup_forge
export PR_STATE=closed PR_MERGED=true PR_AUTHOR_ASSOCIATION=NONE
added_task task-001 "From a fork"
check "the deferred mirror is created at merge" 0 \
  "Created issue for task-001 (ready)" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and it is born ready" \
  "POST repos/o/r/issues -f title=task-001 — From a fork -f labels[]=writrun:task -f labels[]=status:ready"

finish
