#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
bash "$NEW_SH" task "A tracked thing" --priority high >/dev/null 2>&1
if [ -f work/tasks/task-001.md ] &&
   grep -q '^status: pending$'      work/tasks/task-001.md &&
   grep -q '^blocked_reason: null$' work/tasks/task-001.md &&
   grep -q '^spec_ref: \[\]$'       work/tasks/task-001.md &&
   grep -q '^priority: high$'       work/tasks/task-001.md &&
   grep -q '^completed: null$'      work/tasks/task-001.md; then
  echo "ok    a generated task carries every field explicitly"; pass=$((pass + 1))
else
  echo "FAIL  a generated task carries every field explicitly"; fail=$((fail + 1))
fi

finish
