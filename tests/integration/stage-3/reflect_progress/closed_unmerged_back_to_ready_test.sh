#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Closed without merging: the work is not done, and nothing reserves the
# task — it is available again.
setup_forge
export PR_STATE=closed PR_MERGED=false PR_HEAD_REF="spec/003-search"
base_spec spec-003 task-005
forge_issue 31 open "writrun:task,status:in-review" "task-005 — Search"
check "a dead PR returns its task to ready" 0 \
  "task-005 → status:ready (#7 closed unmerged)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the mirror reads ready again" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:ready"

finish
