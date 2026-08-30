#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
printf 'rule\n' >> docs/product/chapter.md
task_file task-001 pending ""
commit_all
check "an authoring change with derived tasks passes" 0 "Derived work present" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
