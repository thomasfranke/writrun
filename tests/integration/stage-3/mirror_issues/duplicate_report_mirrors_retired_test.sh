#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The report list heals the same way the task list does: the race that
# minted #234 and #235 (report-0038) was a report's, so the rule is
# pinned on the kind that bled first — oldest open survives, the
# younger closes naming it.
setup_forge
added_report report-004 "The mirror lagged"
forge_report_issue 20 open "writrun:report,status:open" "[REPORT-004] The mirror lagged"
forge_report_issue 23 open "writrun:report,status:open" "[REPORT-004] The mirror lagged"
check "the younger report duplicate is retired" 0 \
  "#23 retired as a duplicate report mirror — #20 survives" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the close names not planned" \
  "PATCH repos/o/r/issues/23 -f state=closed -f state_reason=not_planned"
forge_not_told "the survivor is not closed" \
  "PATCH repos/o/r/issues/20 -f state=closed"

finish
