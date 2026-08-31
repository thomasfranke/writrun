#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Ids are never reused, even after a delete. The file has to have been
# committed first — an id that only ever existed in a working tree never
# existed as far as the project is concerned.
setup
bash "$NEW_SH" task "First" --origin rule >/dev/null 2>&1
commit_all
rm work/tasks/task-0001-first.md
commit_all
bash "$NEW_SH" task "After a delete" --origin rule >/dev/null 2>&1
if [ -f work/tasks/task-0002-after-a-delete.md ]; then
  echo "ok    a deleted task's id is not reused"; pass=$((pass + 1))
else
  echo "FAIL  a deleted task's id is not reused"; fail=$((fail + 1))
fi

finish
