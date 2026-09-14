#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The shape #261 and #262 reached `ready` in: the heading is there, the
# template's instructional comment is there, and the answer never was.
# Every completion gate ran green over it, because none of them looked.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What

The change, described.

## How to test

<!-- The reviewer's answer, and a different question from the one above:
     what to run to watch the change work, and what to expect back. -->
MD

check "a heading over its seeded comment is refused" 1 "## How to test" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# And a heading over nothing at all is the same refusal — one definition
# covers both, because with the comments removed the two are the same
# section.
forge_pr_body 7 <<'MD'
## What

The change, described.

## How to test
MD

check "and so is a heading over nothing" 1 "## How to test" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# The section that *was* answered is not dragged in with it: a refusal
# that named every heading would tell the author nothing.
refute "the answered section is not named" "## What" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

finish
