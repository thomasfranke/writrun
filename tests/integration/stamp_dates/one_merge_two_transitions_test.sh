#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Each task gets only the field its own transition earned — and a task
# added already completed (tracked work shipped with its own change)
# earned both at once.
setup
git checkout -q main
task_file task-0001 in-progress ""
commit_all
sed -i.bak 's/^status: in-progress$/status: completed/' work/tasks/task-0001.md && rm -f work/tasks/*.bak
task_file task-0002 pending ""
task_file task-0003 completed ""
commit_all

bash "$CI_SCRIPTS/pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z > "$WORK/out" 2>&1

want() {   # want <name> <file> <line>
  if grep -qx "$3" "$2"; then
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n' "$1"; grep -E '^(queued|merged):' "$2" | sed 's/^/      | /'
    fail=$((fail + 1))
  fi
}

want "the completed task earned merged, not queued" \
  work/tasks/task-0001.md "merged: 2026-08-29T12:00:00Z"
want "and its queued stayed null — an earlier merge queued it" \
  work/tasks/task-0001.md "queued: null"
want "the added task earned queued" \
  work/tasks/task-0002.md "queued: 2026-08-29T12:00:00Z"
want "and not merged" work/tasks/task-0002.md "merged: null"
want "a task born completed earns queued" \
  work/tasks/task-0003.md "queued: 2026-08-29T12:00:00Z"
want "and merged in the same merge" \
  work/tasks/task-0003.md "merged: 2026-08-29T12:00:00Z"

finish
