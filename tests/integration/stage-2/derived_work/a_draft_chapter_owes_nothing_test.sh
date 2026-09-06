#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A chapter that declares itself a draft is not a rule, so a change that
# only touches drafts commits the project to nothing and has nothing to
# declare. This is the case the whole marker exists for: documentation
# reaching stakeholders on the authority branch without deriving work
# nobody agreed to.
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Not a rule yet\n\nStakeholders read this.\n' \
  > docs/product/draft-chapter.md
commit_all
export PR_BODY=$'## What\nx\n'
check "a chapter born a draft owes no declaration" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# And editing it on a later push is the same answer: a draft at both ends
# was never a rule in this change.
printf 'More of it.\n' >> docs/product/draft-chapter.md
commit_all
check "and editing it later owes none either" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# Deleting a draft is free for the same reason — the project was never
# held to it.
git rm -q docs/product/draft-chapter.md
commit_all
check "and deleting it owes none" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
