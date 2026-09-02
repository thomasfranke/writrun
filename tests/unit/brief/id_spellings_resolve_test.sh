#!/usr/bin/env bash
# A person types a number, a task file says task-0001, and a branch says
# something in between. Every spelling of the number names one file.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""

check "a bare number resolves"      0 "task-001" -- bash "$BRIEF" 1
check "a padded number resolves"    0 "task-001" -- bash "$BRIEF" 0001
check "the id as written resolves"  0 "task-001" -- bash "$BRIEF" task-001
check "a wider spelling resolves"   0 "task-001" -- bash "$BRIEF" task-0001

finish
