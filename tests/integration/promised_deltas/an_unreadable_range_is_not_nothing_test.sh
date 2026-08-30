#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The deltas check decides whether a completed change touched everything
# its spec promised. Reading nothing and reporting "not applicable" is the
# shape of a promise silently unkept.
setup
task_file task-001 done spec-001
spec_file spec-001 task-001 implemented
commit_all

check "an unreadable range is refused, with git's own words" 3 "fatal:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promised_deltas.sh" nosuchref...HEAD
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/check_promised_deltas.sh" nosuchref...HEAD 2>&1 || true)
if printf '%s' "$out" | grep -q "not applicable"; then
  echo "FAIL  and never claims it looked and found nothing"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
else
  echo "ok    and never claims it looked and found nothing"; pass=$((pass + 1))
fi

finish
