#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The comment is not what makes a section unanswered — the emptiness is.
# An author who answers beside the instruction rather than over it has
# answered, and a check that insisted the comment be deleted would be
# enforcing housekeeping under the name of a rule about reviewers.
setup
stub_forge
forge_pr_body 7 <<'MD'
## How to test

<!-- The reviewer's answer: what to run, and what to expect back. -->

    bash tests/run.sh

Expect 480 case files passed, 0 failed.
MD

check "an answer beside the seeded comment passes" 0 "is answered" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# The other direction, and the reason the comments are stripped rather
# than merely recognised: an answer written *inside* a comment renders as
# nothing on the page, so the reviewer it was owed to never saw it.
forge_pr_body 7 <<'MD'
## How to test

<!-- Run bash tests/run.sh and expect 480 passed. -->
MD

check "an answer written inside a comment is not an answer" 1 "## How to test" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# And a comment spanning lines is one comment, not a first line that
# closes and a remainder that counts as text.
forge_pr_body 7 <<'MD'
## How to test

<!-- Run:
     bash tests/run.sh
     and expect 480 passed. -->
MD

check "a multi-line comment is stripped whole" 1 "## How to test" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

finish
