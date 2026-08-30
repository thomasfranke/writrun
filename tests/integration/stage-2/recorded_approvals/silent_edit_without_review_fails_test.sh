#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

setup
stub_gh 0
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'quietly widened scope\n' >> work/specs/spec-001.md
commit_all
check "editing an approved spec with no status move fails without a review" 1 "no status move" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_recorded_approvals.sh" main...HEAD o/r 1

finish
