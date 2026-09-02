#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The case only this loop can reach. A report recorded `open` in one
# commit and triaged in a later one *of the same open pull request* has a
# mirror already labelled `status:proposed`, and the re-projection path
# cannot see it: project_pr_tasks.sh learns its ids from the head branch
# name and the title's [TASK-NNNN] tags, and a report has neither by
# design. So this pass updates an existing mirror on every synchronize
# rather than only creating missing ones — or the Issue keeps saying the
# report is waiting when the branch already ended it.
setup_forge
added_report report-0003 "Seen, then decided" declined "" 2026-08-23T01:00:00Z
forge_report_issue 12 open "writrun:report,status:proposed" "[REPORT-0003] Seen, then decided"
check "the mirror is closed without waiting for the merge" 0 \
  "closed as not_planned" -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and it really closes, on an open pull request" \
  "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=not_planned"

# A modification is where triage lands when the report is already on the
# authority branch — and its patch carries no `id:` line at all, so the
# id has to come from the path.
setup_forge
export PR_STATE=closed PR_MERGED=true
modified_report report-0007 tracked 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "a triage that arrives as an edit is read too" 0 \
  "report-0007 triaged" -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and closes the mirror completed" \
  "PATCH repos/o/r/issues/14 -f state=closed -f state_reason=completed"

# An edit that touched neither the status nor the file's creation says
# nothing about where the report is, and nothing is what this pass then
# does — guessing would be the one thing worse than leaving it.
setup_forge
export PR_STATE=closed PR_MERGED=true
pr_patch modified "work/reports/report-0007.md" <<'PATCH'
@@ -12,3 +12,4 @@
 # Already on main
 
+One more line of evidence.
PATCH
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "an edit that says nothing changes nothing" 0 \
  "says nothing about its status" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "the mirror is left exactly as it was" "issues/14"

finish
