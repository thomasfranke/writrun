#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
stub_gh 0
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
commit_all
check "a spec born approved with no authorized review fails" 1 "FORBIDDEN" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_recorded_approvals.sh" main...HEAD o/r 1

finish
