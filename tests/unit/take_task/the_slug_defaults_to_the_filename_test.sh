#!/usr/bin/env bash
# The slug in the filename is the one a human chose when the task was
# created; the branch inherits it rather than inventing a second name for
# the same work.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
mv work/tasks/task-001.md work/tasks/task-001-mirror-lag.md
commit_all
publish_main

check "the take succeeds" 0 "Took task-001" -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"
if git rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null; then
  echo "ok    the branch carries the filename's subject"; pass=$((pass + 1))
else
  echo "FAIL  the branch carries the filename's subject"; git branch | sed 's/^/      | /'; fail=$((fail + 1))
fi

take_setup
task_file task-001 ready ""
mv work/tasks/task-001.md work/tasks/task-001-mirror-lag.md
commit_all
publish_main
check "a given slug wins over it" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug queue-impact
if git rev-parse --verify --quiet refs/heads/task/0001-queue-impact >/dev/null; then
  echo "ok    and the branch carries the given one"; pass=$((pass + 1))
else
  echo "FAIL  and the branch carries the given one"; git branch | sed 's/^/      | /'; fail=$((fail + 1))
fi

finish
