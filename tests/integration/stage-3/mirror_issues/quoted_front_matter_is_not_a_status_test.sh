#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A report's body quotes front matter, because that is what its evidence
# is: "the file says `status: open` and the mirror says otherwise". Read
# by a grep for `^status:`, that fence *is* the report's status — so a
# body-only edit adding evidence closed the mirror of a report still open,
# and evidence quoting `status: open` could reopen a triaged one.
#
# The block is bounded instead: the base-branch checkout says where the
# file's front matter ends, and a line outside it is a line about
# something else.
setup_forge
export PR_STATE=closed PR_MERGED=true
base_report report-0007 open
pr_patch modified "work/reports/report-0007.md" <<'PATCH'
@@ -10,3 +10,8 @@
 # Already on main

+The file on `main` reads:
+
+```
+status: declined
+```
PATCH
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "evidence quoting a status is not the report's status" 0 \
  "says nothing about its status" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "so the mirror is not closed" "issues/14 -f state=closed"

# ...and the same line inside the block still is one. The bound is where
# the front matter ends, not a refusal to read it.
setup_forge
export PR_STATE=closed PR_MERGED=true
modified_report report-0007 declined 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "a real status line still moves the mirror" 0 "report-0007 triaged" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and closes it not planned" \
  "PATCH repos/o/r/issues/14 -f state=closed -f state_reason=not_planned"

# The other half of the same bug: with no status to read, the row's empty
# field used to collapse on the tab-separated read and the *title* landed
# where the status belongs. A heading that happens to be a status word is
# then a triage nobody wrote.
setup_forge
export PR_STATE=closed PR_MERGED=true
base_report report-0007 open
pr_patch modified "work/reports/report-0007.md" <<'PATCH'
@@ -10,2 +10,3 @@
 # fixed

+One more line of evidence.
PATCH
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] fixed"
check "a heading is never read as a status" 0 \
  "says nothing about its status" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "the mirror is not closed completed" \
  "issues/14 -f state=closed -f state_reason=completed"

finish
