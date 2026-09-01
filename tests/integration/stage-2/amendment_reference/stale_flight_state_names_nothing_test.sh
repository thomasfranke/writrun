#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A task reading `in-progress` with no open pull request is work abandoned
# without the forge hearing about it. There is no number to name, and
# failing the amendment over somebody else's stale field would block the
# one change that fixes the queue.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0009 task-0007 draft
commit_all
stub_forge
export PR_BODY=$'## What\nThe promise was wrong.'
check "a stale flight state names nothing and fails nothing" 0 "nothing to name" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9

finish
