#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 blocked ""
sed -i.bak 's/^blocked_reason: null$/blocked_reason: upstream release/' work/tasks/task-001.md
rm -f work/tasks/task-001.md.bak
check "a blocked task names its reason" 1 "upstream release" -- bash "$LIST_TASKS"

finish
