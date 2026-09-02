#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Each of the four ends. Triage ended the report, and an ended report
# asks nothing of anyone.
for end in tracked authored fixed declined; do
  setup
  task_file task-001 ready spec-001
  spec_file spec-001 task-001 approved
  report_file report-0007 "$end" "" 2026-08-23T00:00:00Z
  refute "a ${end} report is named nowhere" "report-0007" -- bash "$LIST_TASKS"
done

finish
