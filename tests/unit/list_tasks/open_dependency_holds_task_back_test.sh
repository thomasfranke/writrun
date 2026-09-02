#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
task_file task-002 ready ""
sed -i.bak 's/^depends_on: \[\]$/depends_on: [task-001]/' work/tasks/task-002.md
rm -f work/tasks/task-002.md.bak
check "an open dependency holds a task back" 0 "waiting on task-001" -- bash "$LIST_TASKS"

finish
