#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Content is the test, never length and never quality. A gate that
# weighed the prose would be performing review, which is the line this
# methodology draws everywhere else.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What

Typo.

## How to test

Nothing runnable ships here.
MD

check "one word answers, and so does a declared none" 0 "is answered" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# The same reasoning that makes an authoring change write "none" under
# Derived work rather than leave it blank: an empty section and a
# forgotten one look identical, and a stated none is neither.
finish
