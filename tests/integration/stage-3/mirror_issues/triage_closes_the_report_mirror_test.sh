#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The four ends collapse into two closes: acted on, or not. A `route:`
# label would carry the remaining distinction and is not worth a fifth
# thing for the machinery to keep true — the file says which route was
# taken (docs/product/stage-3-github-issues/labels.md#the-report-mirror).

for st in tracked authored fixed; do
  setup_forge
  export PR_STATE=closed PR_MERGED=true
  added_report report-0003 "Acted on" "$st" task-0009 2026-08-23T01:00:00Z
  forge_report_issue 12 open "writrun:report,status:open" "[REPORT-0003] Acted on"
  check "'${st}' closes the mirror completed" 0 "closed as completed" \
    -- bash "$MIRROR_ISSUES" o/r 7
  forge_told "'${st}' really tells the forge completed" \
    "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=completed"
  forge_not_told "and leaves no status label on it ('${st}')" "labels[]=status:"
done

setup_forge
export PR_STATE=closed PR_MERGED=true
added_report report-0003 "Not a defect" declined "" 2026-08-23T01:00:00Z
forge_report_issue 12 open "writrun:report,status:open" "[REPORT-0003] Not a defect"
check "declined closes the mirror not planned" 0 "closed as not_planned" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "declined really tells the forge not planned" \
  "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=not_planned"

# Declining is where a person sees the judgement and can disagree with
# it, so the close is the only thing that separates it from the three —
# and the mirror must not also be scrubbed of what a person added.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_report report-0003 "Not a defect" declined "" 2026-08-23T01:00:00Z
forge_report_issue 12 open "writrun:report,status:open,needs-discussion" "[REPORT-0003] Not a defect"
check "a hand-added label survives the close" 0 "closed as not_planned" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the label a person put there is re-stated" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:report -f labels[]=needs-discussion"

finish
