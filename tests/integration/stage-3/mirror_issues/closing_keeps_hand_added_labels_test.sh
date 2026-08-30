#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Stripping is surgical: only the `status:` label is the machinery's, and
# a project's own labels outlive every move it makes — including the last
# one.
setup_forge
export PR_STATE=closed PR_MERGED=false
added_task task-001 "Never landed"
forge_issue 12 open "writrun:task,status:proposed,good first issue" "[TASK-001] Never landed"
check "a dead PR retires its mirrors" 0 "closed — #7 was not merged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "every non-status label is kept" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=good first issue"
forge_not_told "and only the status one goes" \
  "-f labels[]=status:"

finish
