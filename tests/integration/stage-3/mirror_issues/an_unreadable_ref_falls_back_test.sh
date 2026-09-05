#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The link is best-effort, like every other write this pass makes. Where
# the pull request's own record cannot be read, neither ref is known — and
# a mirror that points at the diff is better than a mirror that fails to
# be written, which is the one state this reconciliation may not leave
# behind.
setup_forge
forge_refs_unreadable
added_task task-0004 "Something to do"

check "an unreadable pull request still mints the mirror" 0 \
  "Created issue for task-0004" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "linking the diff, which is where the sentence pointed before" \
  "/pull/7/files"

# A body somebody edited by hand keeps its text. The rewrite is here to
# keep a link true, not to reclaim a maintainer's prose — so a first line
# that is not the sentence this script writes is left exactly as it is.
setup_forge
forge_head 1a2b3c4d5e6f7890abcdef1234567890abcdef12 trunk
export PR_STATE=closed PR_MERGED=true
added_task task-0004 "Something to do"
forge_issue 12 open "writrun:task,status:proposed" "[TASK-0004] Something to do"

check "a merge over a hand-written body runs clean" 0 "" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and rewrites nothing into it" \
  "blob/trunk/work/tasks/task-0004.md"

finish
