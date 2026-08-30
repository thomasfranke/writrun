#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 draft
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 approved
commit_all
check "draft -> approved is rejected" 1 "FORBIDDEN" -- bash "$CHECK_STATE" main...HEAD

finish
