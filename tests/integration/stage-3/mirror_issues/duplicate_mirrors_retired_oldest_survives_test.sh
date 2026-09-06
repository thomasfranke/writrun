#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Two mirrors for one record — the race report-0038 observed: two runs a
# second apart each missed the other's mint. The reconciler retires the
# younger naming the survivor, and the survivor keeps answering the
# lookup, so no third mirror is minted over the pair.
setup_forge
added_task task-001 "Add search"
forge_issue 12 open "writrun:task,status:proposed" "[TASK-001] Add search"
forge_issue 15 open "writrun:task,status:proposed" "[TASK-001] Add search"
check "the younger duplicate is retired naming the survivor" 0 \
  "#15 retired as a duplicate task mirror — #12 survives" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the close names not planned" \
  "PATCH repos/o/r/issues/15 -f state=closed -f state_reason=not_planned"
forge_told "the comment names the survivor" \
  "POST repos/o/r/issues/15/comments -f body=Duplicate mirror of one record — #12 is the mirror."
forge_not_told "the survivor is not closed" \
  "PATCH repos/o/r/issues/12 -f state=closed"
forge_not_told "no third mirror is minted" \
  "POST repos/o/r/issues -f title="

finish
