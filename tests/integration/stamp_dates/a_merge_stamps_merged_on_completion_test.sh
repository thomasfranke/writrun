#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `merged` records the merge that took the work, which is a different
# question from when the worker finished — `completed`. Where everything
# merges the same day they coincide; anywhere else the gap is the review.
setup
git checkout -q main
task_file task-0001 in-progress ""
commit_all
sed -i.bak 's/^completed: null$/completed: 2026-08-29T10:00:00Z/' work/tasks/task-0001.md && rm -f work/tasks/*.bak
commit_all

check "completing a task stamps merged" 0 "stamped merged" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z
if grep -qx "merged: 2026-08-29T12:00:00Z" work/tasks/task-0001.md; then
  echo "ok    with the timestamp it was given"; pass=$((pass + 1))
else
  echo "FAIL  with the timestamp it was given"; fail=$((fail + 1))
fi

# The status is read from the front matter, never from the diff — a body
# may quote `status: completed` at column 0, and this repository's docs do.
setup
git checkout -q main
task_file task-0002 ready ""
commit_all
printf '\nA body line quoting the schema:\n\ncompleted: 2026-08-29T10:00:00Z\n' >> work/tasks/task-0002.md
commit_all
check "a body quoting a status is not a transition" 0 "" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z
if grep -qx "merged: null" work/tasks/task-0002.md; then
  echo "ok    and nothing was stamped"; pass=$((pass + 1))
else
  echo "FAIL  and nothing was stamped"; fail=$((fail + 1))
fi

finish
