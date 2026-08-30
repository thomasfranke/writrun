#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Ids and logins arrive from the forge as data. An unknown id moves
# nothing and is not an error; a malformed login writes nothing; a
# missing mode is the one loud exit.
setup
task_file task-001 ready ""
check "an unknown id moves nothing" 0 "resolves to no file" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" take task-999 somebody draft
check "a malformed login writes nothing" 0 "not a bare forge login" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" take task-001 'someone; rm -rf /' draft
check "a missing mode is a usage error" 3 "usage" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_task_status.sh" "" task-001

finish
