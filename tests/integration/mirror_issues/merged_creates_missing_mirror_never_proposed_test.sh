#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The catch-up path: a merge finds a task with no mirror at all, because
# the open event was missed or deferred. The queue holds the task now, so
# it is labelled by the merged rules — `proposed` would say the opposite
# of what the merge just made true.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-001 "Caught up at merge" spec-001
added_spec spec-001 task-001 draft
check "a merge creates the mirror it never had" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "labelled pending, because a spec is still draft" \
  "-f labels[]=writrun:task -f labels[]=status:pending"
forge_not_told "and never proposed" \
  "-f labels[]=status:proposed"

finish
