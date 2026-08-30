#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A spec the diff does not carry is already on main, where the check gate
# vouched for it — so a merged task whose specs all sit there is ready.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-001 "Now ready" spec-001
forge_issue 12 open "writrun:task,status:proposed" "task-001 — Now ready"
check "a merged task with vouched specs is ready" 0 \
  "task-001 is ready for development" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror is relabelled ready" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=status:ready"

finish
