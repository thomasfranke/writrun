#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The filter is "carries the marker **and** mirrors no file", and the
# second half is what makes a label applied by hand harmless: a marker
# put on an issue that is already a report's mirror must not produce a
# second listing
# (docs/product/stage-3-github-issues/intake.md#submitted-and-not-yet-a-report).
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved

# Two ways an issue is already some file's mirror. The title tag is the
# forge's own word for it — and the queue's word is the `Issue #N` line
# the intake writes, which survives an intake that died before the
# retitle and a title a stranger edited afterwards.
report_file report-0007 open
printf '\nIssue #161, opened by @someone.\n' >> work/reports/report-0007.md

export WRITRUN_SUBMITTED_LIST=$'155\t[REPORT-0004] Already a mirror\n161\tThe retitle never happened\n170\tAn observation with no file'

refute "a tagged title is not named a second time" "#155" -- bash "$LIST_TASKS"
refute "nor is one the queue already names" "#161" -- bash "$LIST_TASKS"
check "and the one owed a file still is" 0 "#170" -- bash "$LIST_TASKS"

# A task's mirror is not this section's either — it mirrors a file too,
# and one of another kind entirely.
export WRITRUN_SUBMITTED_LIST=$'181\t[TASK-0012] A task the marker landed on'
refute "a task mirror is left alone" "#181" -- bash "$LIST_TASKS"
refute "and the heading is not printed for an empty set" "waiting for a report" \
  -- bash "$LIST_TASKS"

finish
