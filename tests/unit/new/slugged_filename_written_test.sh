#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The filename carries the id and a very short echo of the title, so a
# directory listing of the queue reads as a summary of it. Identity is
# still the id, and the file must agree with the one it holds.
setup
bash "$NEW_SH" task "Mirror the queue into Issues" >/dev/null 2>&1
if [ -f work/tasks/task-0001-mirror-the-queue.md ] &&
   grep -q '^id: task-0001$' work/tasks/task-0001-mirror-the-queue.md; then
  echo "ok    a generated task is named <id>-<subject>, agreeing with its id"; pass=$((pass + 1))
else
  echo "FAIL  a generated task is named <id>-<subject>, agreeing with its id"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
