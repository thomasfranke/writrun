#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The same change, one line richer. The line is all that was ever missing
# in the case this rule came from — and it was there, and unread.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0009 task-0007 draft
commit_all
stub_forge
forge_open_pr 7 task/0007-thing "[TASK-0007][Feat] the work"
export PR_BODY=$'## What\nSuspends #7 — task-0007 waits on this amendment.'
check "naming the suspended pull request passes" 0 "#7 is named" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9

finish
