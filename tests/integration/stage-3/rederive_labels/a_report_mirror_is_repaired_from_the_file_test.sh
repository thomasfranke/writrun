#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The same projection, one kind over. It matters more here than for a
# task: no forge event corresponds to a triage — the judgement is the
# point, and a merge cannot make it — so this pass is the only reader
# that ever comes back for a report mirror that drifted.
setup_forge
base_report report-0003 open
forge_report_issue 31 open "writrun:report,status:proposed" "[REPORT-0003] Waiting"
check "a report on the authority branch is open, never proposed" 0 \
  "report-0003 → status:open" -- bash "$REDERIVE_LABELS" o/r report-0003
forge_told "the drifted label is restated from the file" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:report -f labels[]=status:open"

setup_forge
base_report report-0003 declined "" 2026-08-23T01:00:00Z
forge_report_issue 31 open "writrun:report,status:open,needs-discussion" "[REPORT-0003] Not a defect"
check "a triaged report closes, from the file" 0 "closed as not_planned" \
  -- bash "$REDERIVE_LABELS" o/r report-0003
forge_told "no status label survives the close, and a person's does" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:report -f labels[]=needs-discussion"

# A project that never recorded a report must not pay a forge call per
# merge for a list that would always come back empty.
setup_forge
base_task task-0005 ready ""
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] A task"
check "a run naming no report still labels the task" 0 "task-0005 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r task-0005
forge_not_told "and the report list is never fetched" "labels=writrun:report"

finish
