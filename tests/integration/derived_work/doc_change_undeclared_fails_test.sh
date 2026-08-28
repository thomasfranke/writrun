#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
printf 'rule\n' >> docs/product/chapter.md
commit_all
export PR_BODY=$'## What\nx\n## Derived work\n| Task | Spec |\n| task-NNN | spec-NNN |'
check "a doc change with no tasks and no 'none' fails" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/pull-requests/check_derived_work.sh" main...HEAD

finish
