#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `$(git … || true)` yields the same empty string whether nothing matched
# or nothing ran. This check is a gate, and a gate that passes because git
# failed is worse than no gate: it reports a guarantee it never checked.
setup
mkdir -p docs/product
printf '# Changed\n' > docs/product/chapter.md
commit_all

check "an unreadable range is refused, with git's own words" 3 "fatal:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" nosuchref...HEAD
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" nosuchref...HEAD 2>&1 || true)
if printf '%s' "$out" | grep -q "nothing to declare"; then
  echo "FAIL  and never claims it looked and found nothing"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
else
  echo "ok    and never claims it looked and found nothing"; pass=$((pass + 1))
fi

# A genuinely empty answer still reads exactly as it did.
check "a real empty diff behaves as before" 0 "nothing to declare" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" HEAD~1...HEAD~1

finish
