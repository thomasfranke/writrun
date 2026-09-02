#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The reported situation: every task done, four reports waiting, and the
# session told only that nothing is available. The section names them —
# and the exit code does not move, because a report is not work.
setup
task_file task-001 done spec-001 2026-08-23T00:00:00Z
spec_file spec-001 task-001 implemented
report_file report-0001 open
report_file report-0002 open
check "an empty queue still exits 1" 1 "Nothing is available." -- bash "$LIST_TASKS"
check "and the open report is named anyway" 1 "report-0001" -- bash "$LIST_TASKS"
check "as is the second" 1 "report-0002" -- bash "$LIST_TASKS"
check "under a heading that says what it is for" 1 "waiting to be triaged" -- bash "$LIST_TASKS"

finish
