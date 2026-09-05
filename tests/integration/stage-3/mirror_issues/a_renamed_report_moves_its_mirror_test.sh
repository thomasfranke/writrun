#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A renumber is one act with two halves, and the mirror owes both. The id
# the file lands on is new and has no Issue, so one is minted; the id it
# left is gone, and the mirror that held it is an orphan the sweep at the
# bottom already knows how to retire. Before this, a renamed file was
# neither added nor modified and the pass saw nothing at all — an id
# nobody could see was also an id nobody could triage.
#
# The rename carries no patch, so everything the mint needs is read from
# the file the base branch still holds at the path the rename left.
setup_forge
mkdir -p work/reports
cat > work/reports/report-0001-take-task.md <<'RPT'
---
id: report-0001
status: open
task_ref: []
doc_ref: null
created: 2026-08-23T00:00:00Z
triaged: null
---

# Take needs a commit
RPT
pr_renamed work/reports/report-0001-take-task.md work/reports/report-0002-take-task.md
forge_report_issue 18 open "writrun:report,status:proposed" \
  "[REPORT-0001] Take needs a commit"

check "a renamed report is mirrored at the id it lands on" 0 \
  "Created issue for report-0002" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "titled from the file the rename left, which is the same file" \
  "POST repos/o/r/issues -f title=[REPORT-0002] Take needs a commit"
forge_told "and the mirror of the id it vacated retires" \
  "PATCH repos/o/r/issues/18 -f state=closed -f state_reason=not_planned"

finish
