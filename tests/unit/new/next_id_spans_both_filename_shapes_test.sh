#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The id scan reads the digits after the prefix, so a queue holding the
# bare-id files that predate the subject slug alongside slugged ones
# still yields one next number — never a reused id.
setup
task_file task-003 pending ""
bash "$NEW_SH" task "Ninth" >/dev/null 2>&1
bash "$NEW_SH" task "Tenth" >/dev/null 2>&1
if [ -f work/tasks/task-0004-ninth.md ] && [ -f work/tasks/task-0005-tenth.md ]; then
  echo "ok    the next id counts past both filename shapes"; pass=$((pass + 1))
else
  echo "FAIL  the next id counts past both filename shapes"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
