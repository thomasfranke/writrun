#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
spec_file spec-001 task-001 approved product/chapter.md
printf 'edit\n' >> docs/about.md
commit_all
check "MISSING and UNDECLARED together exit 1" 1 "MISSING" \
  -- bash "$CHECK_DELTAS" spec-001 main...HEAD

finish
