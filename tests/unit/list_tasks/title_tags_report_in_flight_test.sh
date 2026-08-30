#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The lister reads the same authority the mirror does: a task tagged in
# an open pull request's title is in flight, whatever the branch is
# named. Without this, a PR carrying two tasks reports only the one its
# branch happens to name, and the other is handed to the next person who
# asks what is available.
setup
task_file task-0004 ready ""
task_file task-0005 ready ""
export WRITRUN_PR_LIST="$(printf '7\ttask/0004-two-at-once\tdana\t[TASK-0004][TASK-0005] feat(mirror): reconcile in one pass')"
out=$(bash "$LIST_TASKS" 2>&1)
if printf '%s' "$out" | grep -q "task-0004 *#7 by @dana" &&
   printf '%s' "$out" | grep -q "task-0005 *#7 by @dana"; then
  echo "ok    every task tagged in a title is reported in flight"; pass=$((pass + 1))
else
  echo "FAIL  every task tagged in a title is reported in flight"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
