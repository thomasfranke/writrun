#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Every mirror minted before the rule carries `task-NNNN — <title>`. A
# lookup that only knows the tag does not report a miss — it mints a
# second mirror for a task that already has one, which is the one failure
# a projection must never produce.
setup_forge
added_task task-001 "Add search"
forge_issue 12 open "writrun:task,status:backlog" "task-001 — Add search"
check "an old-form mirror is found, not remade" 0 "already mirrored" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no duplicate is minted" \
  "POST repos/o/r/issues -f title="

finish
