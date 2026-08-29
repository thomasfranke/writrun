#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
printf 'clarification\n' >> docs/product/chapter.md
commit_all
export PR_BODY=$'## What\nx\n## Derived work\nnone — rule already satisfied\n## Notes'
check "declaring none in the PR body passes" 0 "declared as none" \
  -- bash "$CI_SCRIPTS/pull-requests/check_derived_work.sh" main...HEAD

finish
