#!/usr/bin/env bash
# A brief for a task that does not exist is not an empty brief — it is a
# question about the argument, and the refusal names what was looked for.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""

check "an unresolvable id exits 1" 1 "work/tasks/task-<nnnn>" -- bash "$BRIEF" 99
check "and no argument at all exits 1" 1 "usage" -- bash "$BRIEF"

finish
