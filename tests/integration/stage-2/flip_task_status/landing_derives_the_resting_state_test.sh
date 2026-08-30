#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Leaving flight is a derivation, not a return: an amendment may have
# regressed a spec while the work was in flight, so the resting state is
# read from the specs at exit time.
setup
task_file task-001 in-progress spec-001 null somebody
spec_file spec-001 task-001 draft
check "a landing task with a draft spec rests on backlog" 0 "in-progress -> backlog" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" land task-001

# An empty spec_ref rests on ready — no approval event exists for it,
# and backlog must not be a trap.
task_file task-002 in-review "" null somebody
check "an empty spec_ref lands on ready" 0 "in-review -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" land task-002

finish
