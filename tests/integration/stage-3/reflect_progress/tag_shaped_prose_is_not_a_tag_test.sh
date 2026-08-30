#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Only the leading run counts. A tag-shaped string later in a title is
# prose — reading it as a tag would move a mirror the author never named,
# and a title may legitimately quote one while discussing it.
setup_forge
export PR_HEAD_REF="task/0004-quoting"
export PR_TITLE="[TASK-0004] docs: explain why [TASK-0009] is written that way"
forge_issue 22 open "writrun:task,status:ready" "task-0004 — Leading"
forge_issue 24 open "writrun:task,status:ready" "task-0009 — Only quoted"
check "the leading tag is reflected" 0 "task-0004 → status:in-review" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_not_told "the quoted one is not" "PUT repos/o/r/issues/24/labels"

finish
