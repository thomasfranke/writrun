#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A stale mirror is often a closed one — its pull request closed and the
# orphan sweep retired it. Adopting a closed mirror without reopening it
# would leave the task carrying a `status:` label on an issue the forge
# calls terminal, which contradicts itself.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-001 "Mine now" "spec-001"
added_spec spec-001 task-001 approved
forge_issue 12 closed "writrun:task" "task-001 — Left behind" 99
forge_pr_state 99 closed
check "a closed mirror is adopted at merge" 0 "adopted stale mirror #12" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and reopened" "PATCH repos/o/r/issues/12 -f state=open"
forge_told "and labelled where the task now is" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=status:ready"

finish
