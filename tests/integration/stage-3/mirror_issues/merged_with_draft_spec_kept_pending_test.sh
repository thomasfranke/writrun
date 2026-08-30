#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# "Ready for development" is derived, never stored: a spec the diff
# carries still draft (a fork merged past the convenience flip, an admin
# merge) means the task is not ready, whatever the merge implies.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-001 "Held by its spec" spec-001
added_spec spec-001 task-001 draft
forge_issue 12 open "writrun:task,status:proposed" "task-001 — Held by its spec"
check "a merged task with a draft spec is not ready" 0 \
  "task-001 merged with a spec still draft — kept backlog" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror stays backlog" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=status:backlog"

finish
