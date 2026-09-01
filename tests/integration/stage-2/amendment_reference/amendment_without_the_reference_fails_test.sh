#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The pause has no field and needs none — the relation runs between two
# pull requests, and the forge already holds relations between pull
# requests. What it does not hold is prose discipline, so the reference is
# checked rather than trusted.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0009 task-0007 draft
commit_all
stub_forge
forge_open_pr 7 task/0007-thing "[TASK-0007][Feat] the work"
export PR_BODY=$'## What\nThe promise was wrong, so the spec goes back to draft.'
check "an amendment that names no pull request fails" 1 "rides #7" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9

finish
