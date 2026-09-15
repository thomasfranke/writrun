#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Taking a task opens the draft before the work starts, so a body that
# had to be complete then would be a body written before its own change.
# A draft answers nothing and owes nothing.
setup
stub_forge
forge_pr_body 7 draft <<'MD'
## What

## Why

## How to test
MD

check "a draft passes over a body nobody filled" 0 "is a draft" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# And it says *why* it passed. A pass with no reason reads the same as a
# body that was judged and found complete, which is the one thing this
# run must not be mistaken for.
refute "and never reports the body as answered" "is answered" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# The body was not merely unjudged, it was never fetched: the draft arm
# stands between the two reads. Asserted on the forge's log, because
# nothing in the output could tell the two apart.
: > "$FORGE_LOG"
bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7 >/dev/null 2>&1
forge_told "the draft state was read" "--json isDraft"
forge_not_told "the body was not" "--json body"

finish
