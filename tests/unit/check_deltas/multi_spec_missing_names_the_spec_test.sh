#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
spec_file spec-001 task-001 approved product/chapter.md
spec_file spec-002 task-001 approved about.md
printf 'edit\n' >> docs/product/chapter.md
commit_all
check "an unhonoured promise names which spec made it" 1 "spec-002" \
  -- bash "$CHECK_DELTAS" spec-001,spec-002 main...HEAD

finish
