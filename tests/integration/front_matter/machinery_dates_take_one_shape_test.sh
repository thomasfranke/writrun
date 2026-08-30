#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# There is one date shape in this schema and these two are not an
# exception to it. They are stamped from a merge commit, which is exactly
# where a bare date or a local time would creep in.
setup
task_file task-001 ready ""
sed -i.bak 's/^queued: null$/queued: 2026-08-29/' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a bare date in queued is malformed" 1 \
  "field 'queued' is '2026-08-29'" \
  -- bash "$CHECK_FRONT_MATTER"

task_file task-001 ready ""
sed -i.bak 's/^merged: null$/merged: 2026-08-29T12:00:00+02:00/' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "and an offset in merged is too" 1 \
  "field 'merged' is '2026-08-29T12:00:00+02:00'" \
  -- bash "$CHECK_FRONT_MATTER"

# Null stays legitimate: a task nobody has merged has no such moment.
task_file task-001 ready ""
check "null in either is accepted" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
