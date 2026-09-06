#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A rule withdrawn is a decision, and it owes a declaration exactly as
# an edit does — the draft filter must never make deletion cheaper than
# it was. spec-0082 named this edge; nothing in the suite held the
# check to it until report-0035 found the gap (spec-0084).
setup
export PR_BODY=$'## What\nx\n'

# setup's baseline commits docs/product/chapter.md with no marker: a
# rule at the base of the range, absent at its head.
git rm -q docs/product/chapter.md
commit_all
check "deleting a rule chapter owes a declaration" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

export PR_BODY=$'## Derived work\nnone — the chapter is withdrawn, deliberately\n'
check "and a declaration answers it" 0 "declared as none" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
