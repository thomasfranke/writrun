#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# One mirror per record is the healthy state, and the dedup pass must
# read it as nothing to do: no retire line, no close — the reconciler's
# other answers stand exactly as they stood before the pass existed.
setup_forge
added_task task-001 "Add search"
forge_issue 12 open "writrun:task,status:proposed" "[TASK-001] Add search"
check "a single mirror is left standing" 0 \
  "already mirrored" \
  -- bash "$MIRROR_ISSUES" o/r 7
refute "no retire is spoken" "retired as a duplicate" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no close reaches the forge" \
  "-f state=closed"

finish
