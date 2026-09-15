#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Someone replaced the template wholesale. Nothing is carried, so nothing
# is owed — and the run says which of the two happened, because a pass
# with no words reads exactly like a check that never ran.
setup
stub_forge
forge_pr_body 7 <<'MD'
Fixes the typo in the README's second paragraph. Nothing else.
MD

check "a body with no headings owes nothing, out loud" 0 "no '## ' section" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# An empty body is the same answer for the same reason. The forge hands
# back an empty string for a pull request nobody wrote a body for, and
# that is a complete answer rather than a failed read.
forge_pr_body 7 < /dev/null

check "and neither does an empty one" 0 "no '## ' section" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# `#` and `###` are not the heading this rule is about: the template's
# sections are all `## `, and a body's own title or sub-point is not a
# section anyone promised to answer.
forge_pr_body 7 <<'MD'
# A title

### A sub-point
MD

check "nor do headings at other depths" 0 "no '## ' section" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

finish
