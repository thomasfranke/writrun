#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A rederivation dropped a task file from the diff: its mirror is an
# orphan and closes, while the task still in the diff keeps its mirror.
setup_forge
added_task task-001 "Still here"
forge_issue 12 open "writrun:task,status:backlog" "task-001 — Still here"
forge_issue 13 open "writrun:task,status:backlog" "task-002 — Dropped"
check "a dropped task's mirror closes" 0 "task-002 closed — its task left the diff" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the orphan closes as not planned" \
  "PATCH repos/o/r/issues/13 -f state=closed -f state_reason=not_planned"
forge_not_told "the surviving task's mirror stays open" \
  "PATCH repos/o/r/issues/12 -f state=closed"

finish
