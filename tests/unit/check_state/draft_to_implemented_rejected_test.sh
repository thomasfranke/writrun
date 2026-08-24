#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 implemented
commit_all
check "draft -> implemented is rejected" 1 "skipping approval" -- bash "$CHECK_STATE" main...HEAD

finish
