#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# taken_by is a bare forge login or null, and a login on a task nobody
# has is a claim the forge never made.
setup
task_file task-001 in-progress spec-001 null worker
spec_file spec-001 task-001 approved
check "a login while in flight is canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

task_file task-001 done spec-001 2026-08-22T00:00:00Z worker
sed -i.bak 's/^queued: null$/queued: 2026-08-22T00:00:00Z/; s/^merged: null$/merged: 2026-08-22T00:00:00Z/' work/tasks/task-001.md && rm -f work/tasks/*.bak
spec_file spec-001 task-001 implemented
check "and kept on done — who completed it" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

task_file task-001 ready spec-001 null worker
check "a login on a resting task is rejected" 1 "taken_by is set but status is 'ready'" \
  -- bash "$CHECK_FRONT_MATTER"

task_file task-001 in-progress spec-001 null "@worker"
check "a decorated login is rejected — bare, so nobody is pinged" 1 "not a bare forge login" \
  -- bash "$CHECK_FRONT_MATTER"

finish
