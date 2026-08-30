#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The wiring: each pull-request event reaches the flip script as the
# edge it implies, with the head branch name and login travelling as
# data.
setup
task_file task-0001 ready spec-001
spec_file spec-001 task-0001 approved

export PR_HEAD_REF="task/0001-some-work" PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
check "opened takes the task" 0 "ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
export PR_DRAFT=false
check "ready_for_review moves it to in-review" 0 "in-progress -> in-review" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" ready_for_review
check "changes_requested hands it back" 0 "in-review -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" changes_requested
check "review_requested on a ready PR moves it forward" 0 "in-progress -> in-review" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" review_requested
export PR_DRAFT=true
check "converted_to_draft hands it back too" 0 "in-review -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" converted_to_draft
check "review_requested on a draft writes nothing" 0 "not an in-review signal" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" review_requested
check "closed unmerged lands the task" 0 "in-progress -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
export PR_MERGED=true
check "closed by merging is the merge recording's, not this" 0 "the merge recording owns this move" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
unset PR_HEAD_REF PR_AUTHOR PR_DRAFT PR_MERGED

finish
