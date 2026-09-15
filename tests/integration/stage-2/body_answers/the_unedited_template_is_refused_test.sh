#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The regression closest to what happened on #261 and #262: the kit's own
# template, byte for byte as it ships, presented as a finished body. Read
# from the real file rather than a copy, so that editing the template
# without editing this check is a failing case rather than a quiet one.
setup
stub_forge
forge_pr_body 7 < "$REPO_ROOT/.writrun/templates/pull_request_template.md"

check "the unedited template is not a body" 1 "stand over" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

for section in What Why "How to verify" "How to test" Notes; do
  check "${section} is refused" 1 "## ${section}" \
    -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7
done

# The leading comment block is preamble — it sits above every heading and
# opens no section, so the eight-paragraph instruction the template
# begins with is neither a section nor part of one.
refute "the preamble is not read as a section" "## (untitled)" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# What the template *does* fill stays filled: the three kind-specific
# sections ship with a placeholder bullet under them, and a bullet is
# text. They are the sections an author deletes or rewrites, and this
# check's definition — anything visible is an answer — deliberately does
# not try to tell a placeholder from a real one. Recognising placeholder
# text would be reading the prose, which is the line no gate here
# crosses.
refute "a section shipping a placeholder bullet is not empty" "## Spec" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

finish
