#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# This check is advisory by contract — it never fails a change. An
# advisory that could not look must still say it did not look, so the
# failed read is the one case where it exits non-zero: the lie is "no
# permanent doc changed", not the exit code.
setup
mkdir -p docs/product
printf '# Changed\n' > docs/product/chapter.md
commit_all

check "an unreadable range is refused, with git's own words" 3 "fatal:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_queue_impact.sh" nosuchref...HEAD
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/check_queue_impact.sh" nosuchref...HEAD 2>&1 || true)
if printf '%s' "$out" | grep -q "No permanent doc changed"; then
  echo "FAIL  and never claims it looked and found nothing"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
else
  echo "ok    and never claims it looked and found nothing"; pass=$((pass + 1))
fi

check "and it still passes a change that touched no doc" 0 "No permanent doc changed" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_queue_impact.sh" HEAD~1...HEAD~1

finish
