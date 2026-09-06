#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The marker counts on the first line and nowhere else, and this is not
# fussiness — a chapter that *documents* the marker names it in its prose,
# as authoring.md now does twice. A reader that searched the whole file
# would mark the methodology's own docs as drafts.
#
# The mirror of a failure this repository already had: a report quoting
# front matter in its body was read as carrying that front matter, and a
# mirror was closed on it.
setup
mkdir -p docs/product
printf '# A chapter about the marker\n\nWrite `/// writrun:draft` on the first line.\n' \
  > docs/product/about-the-marker.md
commit_all
export PR_BODY=$'## What\nx\n'
check "the marker named in prose is prose" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# Inside a fence it is on line two at the earliest, which is why the
# chapter can show the marker without becoming one.
setup
mkdir -p docs/product
printf '# Showing it\n\n```\n/// writrun:draft\n```\n' > docs/product/showing.md
commit_all
export PR_BODY=$'## What\nx\n'
check "a marker inside a fence is a shown example" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

# Trailing whitespace is trimmed — a line an editor touched is the same
# declaration.
setup
mkdir -p docs/product
printf '/// writrun:draft   \n# Not a rule yet\n' > docs/product/spaced.md
commit_all
export PR_BODY=$'## What\nx\n'
check "trailing whitespace does not undo the declaration" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
