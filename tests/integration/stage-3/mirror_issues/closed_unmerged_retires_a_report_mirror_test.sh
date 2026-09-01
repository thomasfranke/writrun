#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A `status:proposed` report mirror retires with the pull request that
# proposed it, exactly as a task's does: nothing landed on the authority
# branch, so nothing is owed a mirror.
setup_forge
export PR_STATE=closed PR_MERGED=false
added_report report-0003 "Proposed and abandoned"
forge_report_issue 12 open "writrun:report,status:proposed" "[REPORT-0003] Proposed and abandoned"
check "the mirror retires with the pull request" 0 "#7 was not merged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "closed not planned, with no status label left on it" \
  "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=not_planned"

# And a mirror this pull request never introduced is not its to retire —
# the ownership line is what decides, one kind as the other.
setup_forge
export PR_STATE=closed PR_MERGED=false
added_report report-0003 "Proposed and abandoned"
forge_report_issue 12 open "writrun:report,status:open" "[REPORT-0003] Somebody else's" 9
forge_pr_state 9 open
check "somebody else's mirror is left alone" 0 "" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and never closed" "PATCH repos/o/r/issues/12 -f state=closed"

finish
