#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# When a pull request closes without merging, everything it said about a
# report dies with it — and the sweep that retires its mirrors used to
# read only the open ones. That left the states nothing ever corrected:
# a report living on `main` whose mirror a branch closed and then walked
# away from, and a mirror closed `completed` for a report the queue never
# received. Neither is reachable again: the sweep skips closed mirrors,
# and the label projection only ever sees ids from a merge.
#
# So the reconciliation asks the base branch instead, which is the
# checkout this workflow runs in and the only authority still standing.

# The report is on the branch and untriaged: the mirror is owed to it,
# open, whatever the abandoned branch did to it.
setup_forge
export PR_STATE=closed PR_MERGED=false
base_report report-0007 open
forge_report_issue 14 closed "writrun:report" "[REPORT-0007] Already on main"
check "a mirror closed by an abandoned branch is restored" 0 \
  "report-0007 → status:open" -- bash "$MIRROR_ISSUES" o/r 7
forge_told "reopened" "PATCH repos/o/r/issues/14 -f state=open"
forge_told "and labelled from the branch" \
  "PUT repos/o/r/issues/14/labels -f labels[]=writrun:report -f labels[]=status:open"

# The branch triaged it, so the mirror ends where the branch says — not
# where the pull request that closed unmerged happened to leave it.
setup_forge
export PR_STATE=closed PR_MERGED=false
base_report report-0007 fixed "" 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "a triaged report's mirror closes on the branch's word" 0 \
  "closed completed" -- bash "$MIRROR_ISSUES" o/r 7
forge_told "with the reason the branch's status implies" \
  "PATCH repos/o/r/issues/14 -f state=closed -f state_reason=completed"

# The report never reached the branch, so nothing is owed a mirror — and
# a mirror born closed `completed` inside the abandoned pull request says
# the queue acted on something it never received.
setup_forge
export PR_STATE=closed PR_MERGED=false
added_report report-0003 "Born triaged, then abandoned" fixed "" 2026-08-23T01:00:00Z
forge_report_issue 12 closed "writrun:report" "[REPORT-0003] Born triaged, then abandoned"
check "a report that never landed is retired, closed mirror included" 0 \
  "#7 was not merged" -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and the reason is corrected to not planned" \
  "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=not_planned"

# Nothing to say is still nothing to write: a mirror the branch already
# agrees with is left exactly as it is.
setup_forge
export PR_STATE=closed PR_MERGED=false
base_report report-0007 open
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "a mirror the branch agrees with is left alone" 0 "" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "untouched" "repos/o/r/issues/14"

finish
