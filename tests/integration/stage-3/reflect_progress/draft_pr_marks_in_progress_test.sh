#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A draft is not waiting on review — someone is working. The mirror says
# so: leave the worker alone.
setup_forge
export PR_DRAFT=true PR_HEAD_REF="spec/003-search"
base_spec spec-003 task-005
forge_issue 31 open "writrun:task,status:ready" "task-005 — Search"
check "a draft PR marks its task in progress" 0 \
  "task-005 → status:in-progress (draft #7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the mirror reads in-progress" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:in-progress"

finish
