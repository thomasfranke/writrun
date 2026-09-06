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
# held to it. The draft must stand at the *base* of the range for the
# deletion to be in the diff at all: created and deleted on the same
# branch it nets to nothing, `git diff main...HEAD -- docs` is empty,
# and the case passes under any implementation — the vacuity
# report-0035 found. So the branch lands on main first, and a fresh
# branch does the deleting.
git checkout -q main
git merge -q --ff-only feature
git checkout -qb withdrawal
git rm -q docs/product/draft-chapter.md
commit_all
check "the deletion is visible in the range" 0 "docs/product/draft-chapter.md" \
  -- git diff --name-only main...HEAD -- docs
check "and deleting it owes none" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
