#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The sixth script with this defect, and a gate like the other two: a
# failed read left `mine` empty, which reads as "this change adds no queue
# file" — a clean pass on a collision check that never looked.
setup
stub_forge
task_file task-0007 pending ""
commit_all

check "an unreadable range is refused, with git's own words" 3 "fatal:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" nosuchref...HEAD o/r 7
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" nosuchref...HEAD o/r 7 2>&1 || true)
if printf '%s' "$out" | grep -q "nothing claims an id"; then
  echo "FAIL  and never claims it looked and found nothing"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
else
  echo "ok    and never claims it looked and found nothing"; pass=$((pass + 1))
fi

# A readable range still reaches its verdict unchanged.
check "a readable range still checks the base" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
