#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The legitimate reopen, and the reason the warning is discriminated by
# title rather than fired on every one. A pull request closed unmerged
# retires its report mirrors; reopening it restores them. The mirror is a
# projection of the same file, so its title still names the same finding
# — and a rule of "warn on every reopen" would fire here, on the ordinary
# path, which is the fastest way to teach a reader to ignore the warning.
setup_forge
added_report report-0001 "Take needs a commit"
forge_report_issue 18 closed "writrun:report" "[REPORT-0001] Take needs a commit" 17
forge_pr_state 17 closed

check "a restored orphan is reopened as it always was" 0 \
  "report-0001 → status:proposed" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the reopen still happens" \
  "PATCH repos/o/r/issues/18 -f state=open"
refute "and nothing warns about a different finding" \
  "names a different finding" \
  -- bash "$MIRROR_ISSUES" o/r 7

# A mirror this pull request already owns is one it created, and its
# title moving is the pull request editing its own report. Nothing to
# warn about, whatever the titles say.
setup_forge
added_report report-0001 "A heading somebody reworded"
forge_report_issue 18 closed "writrun:report" "[REPORT-0001] The old heading" 7
refute "a mirror this pull request owns never warns" \
  "names a different finding" \
  -- bash "$MIRROR_ISSUES" o/r 7

# A status-only edit carries no heading in its patch, so this diff says
# nothing about what the report is called. An absent title is not a
# differing one: nothing is compared and nothing is printed.
setup_forge
base_report report-0001 fixed
pr_patch modified work/reports/report-0001.md <<'PATCH'
@@ -2,7 +2,7 @@
 id: report-0001
-status: fixed
+status: open
 task_ref: []
PATCH
forge_report_issue 18 closed "writrun:report" "[REPORT-0001] A finding by another name" 17
forge_pr_state 17 closed
refute "a diff carrying no title compares none" \
  "names a different finding" \
  -- bash "$MIRROR_ISSUES" o/r 7

finish
