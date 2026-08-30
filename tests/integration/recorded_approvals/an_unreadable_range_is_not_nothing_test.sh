#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# This is the gate behind `draft -> approved`, the one transition an agent
# may never make. "No approval recorded by this change needs verifying" is
# the most dangerous empty answer in the repository.
setup
stub_forge
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
commit_all

check "an unreadable range is refused, with git's own words" 3 "fatal:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_recorded_approvals.sh" nosuchref...HEAD o/r 7
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/check_recorded_approvals.sh" nosuchref...HEAD o/r 7 2>&1 || true)
if printf '%s' "$out" | grep -q "needs verifying"; then
  echo "FAIL  and never claims it looked and found nothing"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
else
  echo "ok    and never claims it looked and found nothing"; pass=$((pass + 1))
fi

finish
