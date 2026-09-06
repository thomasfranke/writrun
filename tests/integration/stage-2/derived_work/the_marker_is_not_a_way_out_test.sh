#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The marker exempts a chapter that was never a rule in this change, and
# nothing else. Three ways it must not become an escape hatch.

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

finish
