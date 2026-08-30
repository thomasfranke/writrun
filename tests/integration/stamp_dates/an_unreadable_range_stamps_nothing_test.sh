#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Less dangerous than a gate — a failed read costs a missing stamp, not a
# false pass — but the same bug, and a date the machinery owes and never
# wrote is invisible afterwards. It refuses rather than stamping nothing
# and exiting 0.
setup
git checkout -q main
task_file task-0001 pending ""
commit_all

check "an unreadable range is refused, with git's own words" 3 "fatal:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" nosuchref...HEAD 2026-08-29T12:00:00Z
if grep -qx "queued: null" work/tasks/task-0001.md; then
  echo "ok    and nothing was stamped"; pass=$((pass + 1))
else
  echo "FAIL  and nothing was stamped"
  grep -E '^(queued|merged):' work/tasks/task-0001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# A readable range still stamps exactly as it did.
bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z >/dev/null
if grep -qx "queued: 2026-08-29T12:00:00Z" work/tasks/task-0001.md; then
  echo "ok    and a readable range still stamps"; pass=$((pass + 1))
else
  echo "FAIL  and a readable range still stamps"; fail=$((fail + 1))
fi

finish
