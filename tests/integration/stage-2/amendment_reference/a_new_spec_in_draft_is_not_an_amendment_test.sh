#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A spec that does not exist at the base cannot be returning to draft: it
# is new work, and new specs start there. The distinction has to be made
# by asking the base tree, not by reading a failed `git show` as an
# answer — the two are the same empty string, and only one of them means
# "nothing is suspended".
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0011 task-0007 draft
commit_all

check "a spec born on the branch suspends nothing" 0 "nothing is suspended" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9

finish
