#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Recording rides any change, so a report may arrive already triaged —
# the ordinary case, not an edge. The Issue must be created closed rather
# than opened and immediately closed: an open item asks somebody to read
# it, and this one has nothing left to ask. Two forge calls because
# creating an Issue takes no state; what must never appear between them
# is a `status:` label.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_report report-0003 "A typo, already fixed" fixed "" 2026-08-23T01:00:00Z
check "a report that arrives triaged is created closed" 0 \
  "closed completed — it arrived triaged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "it is created bare, carrying only its kind" \
  "POST repos/o/r/issues -f title=[REPORT-0003] A typo, already fixed -f labels[]=writrun:report -f body="
forge_told "and closed as completed in the same pass" \
  "PATCH repos/o/r/issues/100 -f state=closed -f state_reason=completed"
forge_not_told "it never wears a status label" "labels[]=status:"

# And the missing `open` phase is not drift to repair: nothing goes
# looking for a state this report never had.
forge_not_told "no relabelling pass follows it" "PUT repos/o/r/issues"

finish
