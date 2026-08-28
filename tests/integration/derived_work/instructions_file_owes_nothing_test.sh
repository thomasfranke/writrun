#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
printf 'meta\n' > docs/writrun-instructions.md
commit_all
check "editing only the instructions file owes no declaration" 0 "nothing to declare" \
  -- bash "$CI_SCRIPTS/pull-requests/check_derived_work.sh" main...HEAD

finish
