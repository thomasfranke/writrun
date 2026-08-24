#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
commit_all
check "a new draft spec is fine (authoring)" 0 "OK" -- bash "$CHECK_STATE" main...HEAD

finish
