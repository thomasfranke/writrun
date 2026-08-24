#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# An open, non-draft PR means the maintainer is the blocker: the mirror
# says in-review — and keeps every label that is not a status.
setup_forge
export PR_HEAD_REF="spec/003-search"
base_spec spec-003 task-005
forge_issue 31 open "writrun:task,bug,status:ready" "task-005 — Search"
check "an open PR marks its task in review" 0 "task-005 → status:in-review (#7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "non-status labels survive the flip" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=bug -f labels[]=status:in-review"

finish
