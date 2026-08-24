#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
spec_file spec-001 task-001 approved product/chapter.md
commit_all
check "promised path untouched is MISSING" 1 "MISSING" -- bash "$CHECK_DELTAS" spec-001 main...HEAD

finish
