#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 done spec-999 2026-08-22
commit_all
check "spec_ref pointing at no file is rejected" 1 "BROKEN" -- bash "$CHECK_STATE" main...HEAD

finish
