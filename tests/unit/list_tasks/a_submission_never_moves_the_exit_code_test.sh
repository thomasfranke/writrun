#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Naming is not selecting, and a submission is not even a report yet. It
# enters no ordering and moves no exit code — 0 still means a task is
# available and 1 still means none is, which is what every caller
# branching on the status depends on.
setup
task_file task-001 done spec-001 2026-08-23T00:00:00Z
spec_file spec-001 task-001 implemented
export WRITRUN_SUBMITTED_LIST=$'155\tAn observation nobody has triaged'

check "an empty queue still exits 1" 1 "Nothing is available." -- bash "$LIST_TASKS"
check "and the submission is named anyway" 1 "#155" -- bash "$LIST_TASKS"

setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
check "real work still exits 0" 0 "task-001" -- bash "$LIST_TASKS"
check "and the submission is named beside it" 0 "#155" -- bash "$LIST_TASKS"

# The ordering is the takeable list, and an issue is not in it: the
# Available section ends before the submitted one begins.
check "the submission is not in the Available section" 0 "" \
  -- bash -c 'out=$(bash "'"$LIST_TASKS"'"); printf "%s" "$out" | sed -n "/^Available/,/^$/p" | grep -q 155 && exit 1; exit 0'

finish
