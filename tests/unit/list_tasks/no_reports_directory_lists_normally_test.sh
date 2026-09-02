#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# An adopter who never recorded one. Zero reports, silently — not an
# error, and no heading billed to every run to serve none.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
rm -rf work/reports
check "a project with no reports directory lists normally" 0 "task-001" -- bash "$LIST_TASKS"
refute "and prints no report heading" "waiting to be triaged" -- bash "$LIST_TASKS"

# Reports exist but none is open: the same silence, for the same reason.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
report_file report-0001 fixed "" 2026-08-23T00:00:00Z
refute "no open report means no heading" "waiting to be triaged" -- bash "$LIST_TASKS"

finish
