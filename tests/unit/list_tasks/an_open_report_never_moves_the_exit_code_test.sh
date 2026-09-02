#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Naming is not selecting. With real work available the code is 0 and
# both sections print; the report is never among the takeable.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
report_file report-0009 open
check "real work still exits 0" 0 "task-001" -- bash "$LIST_TASKS"
check "and the report is named beside it" 0 "report-0009" -- bash "$LIST_TASKS"

# The ordering is the takeable list, and a report is not in it: the
# Available section ends before the report section begins.
check "the report is not in the Available section" 0 "" \
  -- bash -c 'out=$(bash "'"$LIST_TASKS"'"); printf "%s" "$out" | sed -n "/^Available/,/^$/p" | grep -q report-0009 && exit 1; exit 0'

finish
