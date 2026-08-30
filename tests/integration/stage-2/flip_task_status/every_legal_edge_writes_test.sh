#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The happy path around the machine: take, review, rework, land — each
# edge writes exactly the line its event implies.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved

check "a draft PR takes a ready task" 0 "ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" take task-001 somebody draft
grep -qx "taken_by: somebody" work/tasks/task-001.md \
  && { echo "ok    and records who has it"; pass=$((pass+1)); } \
  || { echo "FAIL  and records who has it"; fail=$((fail+1)); }

check "marking it ready for review moves it" 0 "in-progress -> in-review" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" review task-001
check "requesting changes moves it back" 0 "in-review -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" rework task-001
check "closing unmerged lands it on ready" 0 "in-progress -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" land task-001
grep -qx "taken_by: null" work/tasks/task-001.md \
  && { echo "ok    and clears taken_by"; pass=$((pass+1)); } \
  || { echo "FAIL  and clears taken_by"; fail=$((fail+1)); }

# A PR opened ready (never draft) is already waiting on review.
check "a PR opened non-draft lands in-review directly" 0 "ready -> in-review" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" take task-001 somebody ready

finish
