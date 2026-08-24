#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
spec_file spec-001 task-001 approved product/chapter.md
spec_file spec-002 task-001 approved product/chapter.md
printf 'edit\n' >> docs/product/chapter.md
printf 'edit\n' >> docs/about.md
commit_all
check "a doc outside every listed promise is still UNDECLARED" 2 "UNDECLARED" \
  -- bash "$CHECK_DELTAS" spec-001,spec-002 main...HEAD

finish
