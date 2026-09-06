#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The bare-ref shape diffs the ref against the working tree, so the
# draft filter must ask its question of the working tree. Probing HEAD:
# instead dropped every checkout-only path from `perm` — a chapter that
# resolves at neither ref is a rule at neither end, and a dropped path
# turns a refusal into a pass (report-0035, spec-0084).
setup
export PR_BODY=$'## What\nx\n'

# The confirmed regression: a rule chapter that exists only in the
# checkout. Probed at HEAD: it resolved nowhere and left the set.
# Staged, because `git diff <ref>` reports a new file only once the
# index knows it — the diff and the probe must see the same path.
printf '# A rule\n\nThe project is held to this.\n' > docs/product/new-rule.md
git add docs/product/new-rule.md
check "an uncommitted rule chapter owes a declaration" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main

# The same path born a draft owes nothing — the filter still filters.
git rm -qf docs/product/new-rule.md
printf '/// writrun:draft\n# Not a rule yet\n' > docs/product/new-draft.md
git add docs/product/new-draft.md
check "an uncommitted draft chapter owes none" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main

# Removing the marker in the working tree is graduation — authoring, and
# it owes like any other. The base end holds the draft; the checkout
# holds the rule.
git rm -qf docs/product/new-draft.md
printf '/// writrun:draft\n# Growing up\n\nAlmost a rule.\n' > docs/product/grad.md
commit_all
printf '# Growing up\n\nAlmost a rule.\n' > docs/product/grad.md
check "a marker removed in the working tree owes a declaration" 1 "neither adds a task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" HEAD

finish
