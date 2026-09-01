#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The same promise, one path richer — which is all that was ever missing.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md \
  technical/decisions/README.md
commit_all

check "the pair promised whole passes" 0 "every mandatory companion is present" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
