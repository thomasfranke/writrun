#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# dropped is the queue's honest word for "this will not happen": the
# mirror closes as not planned, carrying no status label — and the
# caller may name the task directly, not only through a spec.
setup_forge
base_task task-0005 dropped ""
forge_issue 31 open "writrun:task,status:ready,priority:high" "[TASK-0005] Not happening"
check "a dropped task closes its mirror as not planned" 0 "closed as not_planned" \
  -- bash "$REDERIVE_LABELS" o/r task-0005
forge_told "no status label survives the close" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=priority:high"
forge_told "and the close carries its reason" \
  "PATCH repos/o/r/issues/31 -f state=closed -f state_reason=not_planned"

finish
