#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The merge is what puts the report on the authority branch, and `open`
# is the state the mirror exists for: a report nobody is prompted to read
# is a report that rots, which is the failure the concept exists to end.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_report report-0003 "Something was seen"
forge_report_issue 12 open "writrun:report,status:proposed" "[REPORT-0003] Something was seen"
check "a landed report is open, not proposed" 0 "report-0003 → status:open" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror is relabelled to open" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:report -f labels[]=status:open"
forge_not_told "and is not closed" "state=closed"

finish
