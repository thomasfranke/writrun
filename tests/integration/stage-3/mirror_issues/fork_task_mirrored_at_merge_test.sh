#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The other half of the deferral: at merge the queue really gains the
# task, so the catch-up creation runs — bare, because from the merge on
# the label is the queue's to project and not this script's to guess.
setup_forge
export PR_STATE=closed PR_MERGED=true PR_AUTHOR_ASSOCIATION=NONE
added_task task-001 "From a fork"
check "the deferred mirror is created at merge" 0 \
  "Created issue for task-001 — its label is the projection's" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and it is born with the two labels that are facts" \
  "POST repos/o/r/issues -f title=[TASK-001] From a fork -f labels[]=writrun:task -f labels[]=origin:rule"
forge_not_told "and no status label at all" "labels[]=status:"

finish
