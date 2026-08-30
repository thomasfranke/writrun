#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# An event whose edge does not match the status the task holds is an
# out-of-order echo — not an error, and it never marches a task
# backwards.
setup
task_file task-001 done spec-001 2026-08-22T00:00:00Z somebody
spec_file spec-001 task-001 implemented

check "a reopen against a done task writes nothing" 0 "no edge" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" take task-001 latecomer draft
grep -qx "status: done" work/tasks/task-001.md \
  && { echo "ok    done stands"; pass=$((pass+1)); } \
  || { echo "FAIL  done stands"; fail=$((fail+1)); }
grep -qx "taken_by: somebody" work/tasks/task-001.md \
  && { echo "ok    and so does who completed it"; pass=$((pass+1)); } \
  || { echo "FAIL  and so does who completed it"; fail=$((fail+1)); }

task_file task-002 ready ""
check "a review event against a resting task writes nothing" 0 "no edge" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" review task-002
check "a land against a resting task writes nothing" 0 "no edge" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" land task-002

task_file task-003 blocked ""
sed -i.bak 's/^blocked_reason: null$/blocked_reason: waiting/' work/tasks/task-003.md && rm -f work/tasks/*.bak
check "a take against a blocked task writes nothing" 0 "no edge" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" take task-003 somebody draft

finish
