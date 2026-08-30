#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# When the title carries tags they are the whole set: a branch naming a
# task the title does not name must not add it. Otherwise renaming a
# branch would quietly move a mirror its author never claimed.
setup_forge
export PR_HEAD_REF="task/0009-misleading-name"
export PR_TITLE="[TASK-0004] fix(ci): debounce mirror updates"
forge_issue 22 open "writrun:task,status:ready" "task-0004 — Tagged"
forge_issue 24 open "writrun:task,status:ready" "task-0009 — Named by the branch only"
check "the tagged task is reflected" 0 "task-0004 → status:in-review" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_not_told "the branch's own task is not touched" \
  "PUT repos/o/r/issues/24/labels"

finish
