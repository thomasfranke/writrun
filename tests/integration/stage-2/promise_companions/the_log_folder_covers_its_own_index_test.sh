#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The same reading, applied to the companion: a promise of the log's root
# folder covers the index that lives in it. This gate and the completion
# gate must read a trailing `/` the same way, or one would refuse a promise
# the other accepts and the entry gate would be the more expensive of the
# two.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/
commit_all

check "a folder promise covering both halves is whole" 0 \
  "every mandatory companion is present" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
