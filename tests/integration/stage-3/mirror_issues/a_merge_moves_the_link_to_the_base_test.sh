#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A mirror outlives its pull request, and a reader arriving a year later
# wants the file — not a snapshot of a branch that is gone. So the merge,
# which is when the file stops being a proposal and becomes what the base
# branch holds, moves the link there.
#
# The base ref is read from the pull request, never assumed: `main` is
# this repository's answer and not every adopter's.
setup_forge
forge_head 1a2b3c4d5e6f7890abcdef1234567890abcdef12 trunk
export PR_STATE=closed PR_MERGED=true
added_task task-0004 "Something to do"
forge_issue 12 open "writrun:task,status:proposed" "[TASK-0004] Something to do" 7 \
  work/tasks/task-0004.md

check "a merge rewrites the mirror it owns" 0 "" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "moving the link onto the base ref" \
  "blob/trunk/work/tasks/task-0004.md"
forge_not_told "and off the commit it was born from" \
  "blob/1a2b3c4d5e6f7890abcdef1234567890abcdef12"

# A mirror created *at* merge — the catch-up path, for a pull request
# whose earlier events were missed — is born on the base ref and never on
# a sha. There is no window in which it should point at a commit.
setup_forge
forge_head 1a2b3c4d5e6f7890abcdef1234567890abcdef12 trunk
export PR_STATE=closed PR_MERGED=true
added_report report-0003 "Something observed"

check "a mirror born at merge is created" 0 "Created issue for report-0003" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "already pointing at the base ref" \
  "blob/trunk/work/reports/report-0003.md"
forge_not_told "never at a head sha" \
  "blob/1a2b3c4d5e6f7890abcdef1234567890abcdef12"

finish
