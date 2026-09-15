#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The sibling gates degrade when the forge goes quiet, because there the
# forge is the second half of a question git has already half-answered.
# Here it is the whole question: a run reporting "every section answered"
# without having read the body would be asserting precisely the thing it
# failed to look at. The lie is the verdict, not the exit code.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What

Answered.
MD
forge_unavailable

check "no forge answer is refused, never passed" 3 "could not be read" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

refute "and nothing is claimed about the sections" "is answered" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# The middle view: the draft state answers and the body does not. Without
# it the run would hold a `false` and an empty body, which reads as a
# pull request carrying no sections at all — the pass that looks most
# like a verdict.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What

## Why
MD
forge_refuses "pr view body"

check "a body read that fails alone is refused too" 3 "did not answer" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

refute "and is never reported as a body with no sections" "no '## ' section" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# A draft state that is neither true nor false is an answer this check
# cannot act on, and guessing would decide whether the body is judged at
# all — the difference between a refusal and an unread pass.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What
MD
printf 'null\n' > "$FORGE_DIR/pr_7_draft"

check "an unreadable draft state is refused, not guessed at" 3 "neither true nor false" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

finish
