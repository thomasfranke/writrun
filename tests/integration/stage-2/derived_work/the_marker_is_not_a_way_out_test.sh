#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The marker exempts a chapter that was never a rule in this change, and
# nothing else. Four ways it must not become an escape hatch.

# One: removing it is the authoring act. The chapter becomes a rule in
# this very change, so the change owes exactly what authoring owes.
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Becoming a rule\n\nText.\n' \
  > docs/product/graduating.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf '# Becoming a rule\n\nText.\n' > docs/product/graduating.md
commit_all
export PR_BODY=$'## What\nx\n'
check "removing the marker owes a declaration" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# Two: adding it to a chapter that was a rule is withdrawing a rule, and
# that is a decision a reviewer is shown. Reading only the version the
# change lands would have made demotion cheaper than deletion.
setup
mkdir -p docs/product
printf '# A real rule\n\nText.\n' > docs/product/demoted.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf '/// writrun:draft\n# A real rule\n\nText.\n' > docs/product/demoted.md
commit_all
export PR_BODY=$'## What\nx\n'
check "demoting a rule to a draft owes a declaration" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# Three: one non-draft path is enough. The answer is about the change,
# not per file, so a draft riding beside a real doc change changes
# nothing about what that change owes.
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Not a rule yet\n' > docs/product/draft.md
printf 'a real rule\n' >> docs/product/chapter.md
commit_all
export PR_BODY=$'## What\nx\n'
check "a draft beside a real doc change owes a declaration" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# Four: a rename is not a fresh start. Git reports a detected rename as
# its destination alone, so demoting a rule while moving it would present
# one path that is absent at the base and a draft at the head — case two
# all over again, reached by the one route case two cannot see. The check
# reads renames as an addition and a deletion so that both ends of the
# move are asked the question, and the deleted source is still the rule
# it was.
setup
mkdir -p docs/product
printf '# A real rule\n\nText.\n' > docs/product/moved.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
git mv -f docs/product/moved.md docs/product/elsewhere.md
printf '/// writrun:draft\n# A real rule\n\nText.\n' > docs/product/elsewhere.md
commit_all
export PR_BODY=$'## What\nx\n'
check "renaming a rule while demoting it owes a declaration" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# And a draft moved is still free: the rename changed how the paths are
# reported, not what either end says about itself.
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Not a rule yet\n' > docs/product/wandering.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
git mv -f docs/product/wandering.md docs/product/settled.md
commit_all
export PR_BODY=$'## What\nx\n'
check "and renaming a draft still owes none" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
