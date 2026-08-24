#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending ""
task_file task-002 pending ""
sed -i.bak 's/^priority: medium$/priority: high/' work/tasks/task-002.md
rm -f work/tasks/task-002.md.bak
out=$(bash "$LIST_TASKS" 2>&1)
if [ "$(printf '%s' "$out" | grep -c 'task-00')" -eq 2 ] &&
   printf '%s' "$out" | grep 'task-00' | head -n1 | grep -q 'task-002'; then
  echo "ok    higher priority sorts first"; pass=$((pass + 1))
else
  echo "FAIL  higher priority sorts first"
  printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail + 1))
fi

finish
