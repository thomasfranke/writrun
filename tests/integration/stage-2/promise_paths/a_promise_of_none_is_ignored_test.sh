#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# "none — no behaviour change" is a promise too, and it names no path.
# Nothing to read, so nothing to refuse.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft
commit_all

check "a promise of none names no path to resolve" 0 "nothing to judge" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
