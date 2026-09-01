#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The close keeps what a person added (triage_closes_the_report_mirror),
# and a mirror still open has no weaker claim to it. The relabelling path
# wrote the whole set from the kind and the new status alone, so a label
# a reviewer put on a proposed report was deleted by the next push — on
# every push, and with nothing said about it.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_report report-0003 "Something was seen"
forge_report_issue 12 open "writrun:report,status:proposed,needs-discussion" \
  "[REPORT-0003] Something was seen"
check "the landed report is relabelled open" 0 "report-0003 → status:open" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and the label a person put there is re-stated with it" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:report -f labels[]=status:open -f labels[]=needs-discussion"

# A pass that has nothing to change says so and writes nothing. Two calls
# per live report per push, for a label the mirror already wears, is the
# kind of cost that only shows up as rate limits on a busy branch. The
# label is looked for in a set, not at a position — the forge returns them
# in whatever order it likes, and this one leads with the status.
setup_forge
added_report report-0003 "Something was seen"
forge_report_issue 12 open "status:proposed,writrun:report" \
  "[REPORT-0003] Something was seen"
check "a mirror already saying it is left alone" 0 \
  "report-0003 already mirrored status:proposed; nothing to do." \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "the mirror is not written to at all" "repos/o/r/issues/12"

finish
