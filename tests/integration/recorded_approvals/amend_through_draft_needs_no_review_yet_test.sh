#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The amendment itself (approved -> draft, body edited) records no
# approval — nothing to verify; the gate comes later, at the review.
setup
stub_gh 0
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 draft
commit_all
check "an amendment returning to draft needs no review yet" 0 "No approval recorded" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_recorded_approvals.sh" main...HEAD o/r 1

finish
