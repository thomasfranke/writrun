#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
spec_file spec-001 task-001 approved product/chapter.md
printf 'edit\n' >> docs/product/chapter.md
printf 'edit\n' >> docs/about.md
commit_all
check "an undeclared permanent doc is UNDECLARED" 2 "UNDECLARED" \
  -- bash "$CHECK_DELTAS" spec-001 main...HEAD

finish
