#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The amendment that fixes exactly this omission modifies the spec, so the
# check re-runs over it. It must read the promise as it now stands — a
# gate that still demanded what the amendment just supplied would refuse
# its own remedy.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md \
  technical/decisions/README.md
commit_all

check "the amended promise passes" 0 "every mandatory companion is present" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
