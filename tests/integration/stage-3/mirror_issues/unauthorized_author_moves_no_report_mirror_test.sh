#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Deferral is about every write, not only the creating one. The gate used
# to sit inside the create path, where a report already on the authority
# branch never reaches it: the mirror exists, so an unrecognized author's
# patch claiming `status: declined` fell through to adoption and closed
# the project's own report — with `issues: write`, on
# `pull_request_target`, from a fork.
setup_forge
export PR_AUTHOR_ASSOCIATION=NONE
modified_report report-0007 declined 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "an unrecognized author defers an existing report mirror too" 0 \
  "report-0007: author lacks authority — mirror deferred to merge." \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "the mirror is not closed" "PATCH repos/o/r/issues/14 -f state=closed"
forge_not_told "nor adopted" "PATCH repos/o/r/issues/14 -f body="

# A task's mirror is reached the same way and refused the same way — an
# added task file whose id already has a mirror is not an invitation to
# relabel it.
setup_forge
export PR_AUTHOR_ASSOCIATION=NONE
added_task task-0006 "From a fork"
forge_issue 12 closed "writrun:task" "[TASK-0006] From a fork"
check "and a task's existing mirror is left alone as well" 0 \
  "task-0006: author lacks authority — mirror deferred to merge." \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "not reopened" "PATCH repos/o/r/issues/12 -f state=open"

# Deferred, never denied: the merge is where the queue really gains the
# report, and there the write happens whoever wrote the patch.
setup_forge
export PR_AUTHOR_ASSOCIATION=NONE PR_STATE=closed PR_MERGED=true
modified_report report-0007 declined 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "the merge is where a fork's report lands" 0 "report-0007 triaged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and the mirror closes then" \
  "PATCH repos/o/r/issues/14 -f state=closed -f state_reason=not_planned"

finish
