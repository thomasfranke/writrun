#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A pull request opening for a task already in flight refreshes
# taken_by and the state per its own draftness — the newest event wins,
# and taken_by never strands on a dead PR's author.
setup
task_file task-001 in-progress spec-001 null first-worker
spec_file spec-001 task-001 approved

check "a newer PR supersedes the holder" 0 "moved" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" take task-001 second-worker ready
grep -qx "taken_by: second-worker" work/tasks/task-001.md \
  && { echo "ok    taken_by follows the newest"; pass=$((pass+1)); } \
  || { echo "FAIL  taken_by follows the newest"; fail=$((fail+1)); }
grep -qx "status: in-review" work/tasks/task-001.md \
  && { echo "ok    and the state follows its draftness"; pass=$((pass+1)); } \
  || { echo "FAIL  and the state follows its draftness"; fail=$((fail+1)); }

finish
