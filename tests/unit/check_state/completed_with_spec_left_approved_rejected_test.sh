#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 completed spec-001 2026-08-22
commit_all
check "completed task with a spec left approved is rejected" 1 "INCONSISTENT" \
  -- bash "$CHECK_STATE" main...HEAD

finish
