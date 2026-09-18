#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A pull request carrying a triage only proposes it. Until it merges the
# report is still where the mirror projects from — the authority branch —
# so nothing here closes, and the label is read from the base branch this
# workflow checks out
# (docs/product/stage-3-github-issues/labels.md#the-report-mirror).
#
# Taking the close from the diff instead retired the one state the mirror
# exists for, for the length of the review: issue #282 closed `completed`
# twenty-six seconds after the pull request triaging report-0048 opened,
# while `main` still held the report `open` and the lister still listed
# it (work/reports/report-0048-mirror-closes-early.md).

# Recorded and triaged in one diff. The branch carries neither, so the
# mirror is the proposal it says it is, whatever end the diff names.
setup_forge
added_report report-0003 "Seen, then decided" declined "" 2026-08-23T01:00:00Z
forge_report_issue 12 open "writrun:report,status:proposed" "[REPORT-0003] Seen, then decided"
check "a triage still in flight closes nothing" 0 \
  "already mirrored status:proposed" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "the mirror is not closed on an open pull request" \
  "PATCH repos/o/r/issues/12"

# The same report with no mirror yet is created, and created *open* at
# `status:proposed`. Born closed is the merge's answer, and the merge is
# where the end this diff names is read
# (a_born_terminal_report_is_created_closed_test.sh).
setup_forge
added_report report-0003 "A typo, already fixed" fixed "" 2026-08-23T01:00:00Z
check "a report born triaged on an open pull request is created proposed" 0 \
  "Created issue for report-0003 (status:proposed)" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and nothing closes it either" "state_reason="

# The case this was written for: the report is on the branch and `open`,
# and this pull request proposes its triage. The Issue asking somebody to
# read it stays open, and stays labelled from the branch.
setup_forge
modified_report report-0007 tracked 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "a report the branch still holds open keeps its mirror" 0 \
  "already mirrored status:open" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and nothing closes it" "PATCH repos/o/r/issues/14"

# And where the mirror is not yet wearing the branch's label it gets it —
# `status:open`, the state the branch holds, never the `status:proposed`
# a report this pull request merely offers would wear.
setup_forge
modified_report report-0007 fixed 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report" "[REPORT-0007] Already on main"
check "the label comes from the branch, not from the diff" 0 \
  "report-0007 → status:open" -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and it is the state the branch really holds" \
  "PUT repos/o/r/issues/14/labels -f labels[]=writrun:report -f labels[]=status:open"

# The branch has it triaged already, so its mirror is closed and closed is
# where it belongs. A later pull request touching the file must not reopen
# an Issue asking for a triage that has happened.
setup_forge
base_report report-0007 fixed "" 2026-08-23T01:00:00Z
pr_patch modified "work/reports/report-0007.md" <<'PATCH'
@@ -2,5 +2,5 @@
 id: report-0007
-status: open
+status: fixed
 task_ref: []
 doc_ref: null
-triaged: null
+triaged: 2026-08-23T01:00:00Z
PATCH
forge_report_issue 14 closed "writrun:report" "[REPORT-0007] Already on main"
check "a mirror the branch has triaged is left closed" 0 \
  "not this pull request's to move" -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "it is not reopened" "issues/14"

# A modification is where triage lands when the report is already on the
# authority branch — and its patch carries no `id:` line at all, so the
# id has to come from the path. At the merge the diff has landed, and the
# close it implies is read from it.
setup_forge
export PR_STATE=closed PR_MERGED=true
modified_report report-0007 tracked 2026-08-23T01:00:00Z
forge_report_issue 14 open "writrun:report,status:open" "[REPORT-0007] Already on main"
check "a triage that arrives as an edit is read at the merge" 0 \
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
