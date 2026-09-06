#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `git diff --name-only` quotes a path holding non-ASCII bytes unless it
# is told not to — `"docs/product/caf\303\251.md"`, escapes and all. The
# draft filter probes each path with `git cat-file`, and that literal
# string resolves at neither end of the range, so the chapter would be
# read as a rule nowhere and drop out of the permanent set. A gate that
# drops a path it could not read turns a refusal into a pass, which is
# the one failure this check exists to prevent.
setup
mkdir -p docs/product
printf '# A real rule\n\nText.\n' > "docs/product/café.md"
commit_all
export PR_BODY=$'## What\nx\n'
check "a chapter whose name git would quote still owes a declaration" 1 \
  "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# And the same chapter as a draft is exempt for the right reason rather
# than by accident — the path was read, and its first line answered.
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Not a rule yet\n' > "docs/product/café.md"
commit_all
export PR_BODY=$'## What\nx\n'
check "and is exempt when it is a draft, having actually been read" 0 \
  "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# Quoting off, git still quotes a path holding a quote character. That
# one cannot be probed at all, so it is refused rather than skipped: the
# sibling promise check draws the line in the same place.
setup
mkdir -p docs/product
printf '# A real rule\n' > 'docs/product/a "quoted" name.md'
commit_all
export PR_BODY=$'## What\nx\n'
check "a path that stays quoted is refused, not skipped" 3 \
  "refusing rather than skipping it" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
