#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The number to name lives only on the forge. Without an answer the check
# cannot know it, so it says its view was narrow rather than failing a
# change over a question it could not ask — the contract the id check
# already states.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0009 task-0007 draft
commit_all
stub_forge
forge_unavailable
export PR_BODY=$'## What\nThe promise was wrong.'
check "no forge answer degrades instead of failing" 0 "the forge did not" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9

finish
