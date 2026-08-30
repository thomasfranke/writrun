#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 implemented
task_file task-001 ready spec-001 2026-08-22
commit_all
check "approved -> implemented with the date written passes" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish
