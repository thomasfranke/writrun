#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Only a null field is written. A date already recorded is history, and a
# later merge touching the same file must not restate it as its own.
setup
git checkout -q main
task_file task-0001 ready ""
sed -i.bak 's/^queued: null$/queued: 2026-08-01T09:00:00Z/' work/tasks/task-0001.md && rm -f work/tasks/*.bak
commit_all

check "a merge that adds an already-stamped task rewrites nothing" 0 "" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z
if grep -qx "queued: 2026-08-01T09:00:00Z" work/tasks/task-0001.md; then
  echo "ok    the recorded date stands"; pass=$((pass + 1))
else
  echo "FAIL  the recorded date stands"; fail=$((fail + 1))
fi

finish
