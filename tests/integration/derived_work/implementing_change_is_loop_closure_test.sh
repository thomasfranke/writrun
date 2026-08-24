#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 implemented
printf 'now true\n' >> docs/product/chapter.md
commit_all
check "an implementing change edits docs as loop closure" 0 "loop closure" \
  -- bash "$CI_SCRIPTS/check_derived_work.sh" main...HEAD

finish
