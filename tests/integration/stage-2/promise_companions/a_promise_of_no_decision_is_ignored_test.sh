#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# This check reads one pair and judges nothing else. A spec promising two
# chapters and a technical section owes no companion — the check must not
# grow into a second opinion on what a promise should contain.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  product/chapter.md about.md technical/README.md
commit_all

check "a promise naming no dated entry is left alone" 0 "every mandatory companion is present" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
