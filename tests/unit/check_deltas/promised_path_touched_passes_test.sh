#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
spec_file spec-001 task-001 approved product/chapter.md
printf 'edit\n' >> docs/product/chapter.md
commit_all
check "promised path touched passes" 0 "OK" -- bash "$CHECK_DELTAS" spec-001 main...HEAD

finish
