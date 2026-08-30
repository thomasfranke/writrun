#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A hand-written date cannot honestly record a merge — it would have to
# be typed before the event it describes. So the merge writes it, with
# its own time, and the field a person left null is what it fills.
setup
git checkout -q main
task_file task-0001 pending ""
commit_all

check "a merge adds a task and stamps queued" 0 "stamped queued" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z
if grep -qx "queued: 2026-08-29T12:00:00Z" work/tasks/task-0001.md; then
  echo "ok    with the timestamp it was given"; pass=$((pass + 1))
else
  echo "FAIL  with the timestamp it was given"
  sed -n '1,14p' work/tasks/task-0001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi
if grep -qx "merged: null" work/tasks/task-0001.md; then
  echo "ok    and merged untouched — this merge took no work"; pass=$((pass + 1))
else
  echo "FAIL  and merged untouched — this merge took no work"; fail=$((fail + 1))
fi

finish
