#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
spec_file spec-001 task-001 approved product/chapter.md
commit_all
check "an unknown id anywhere in the list exits 3" 3 "spec-404" \
  -- bash "$CHECK_DELTAS" spec-001,spec-404 main...HEAD

finish
