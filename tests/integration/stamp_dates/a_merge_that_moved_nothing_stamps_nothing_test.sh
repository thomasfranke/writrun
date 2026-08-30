#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The ordinary case: most merges touch no task at all, and one that
# modifies a task without completing it earned neither field.
setup
git checkout -q main
task_file task-0001 pending ""
commit_all
printf 'a docs change\n' > docs/product/chapter.md
commit_all
check "a merge touching no task stamps nothing" 0 "" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z

sed -i.bak 's/^priority: medium$/priority: high/' work/tasks/task-0001.md && rm -f work/tasks/*.bak
commit_all
check "and one that edits a task without completing it stamps nothing" 0 "" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z
if grep -qx "merged: null" work/tasks/task-0001.md; then
  echo "ok    merged is still null"; pass=$((pass + 1))
else
  echo "FAIL  merged is still null"; fail=$((fail + 1))
fi

# A task already completed on the base branch did not complete here.
sed -i.bak 's/^status: pending$/status: completed/' work/tasks/task-0001.md && rm -f work/tasks/*.bak
commit_all
bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-29T12:00:00Z >/dev/null
printf 'a later edit\n' >> work/tasks/task-0001.md
commit_all
check "a task already completed at the base is not completed again" 0 "" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/stamp_task_dates.sh" HEAD~1...HEAD 2026-08-30T12:00:00Z
if grep -qx "merged: 2026-08-29T12:00:00Z" work/tasks/task-0001.md; then
  echo "ok    the first completion's date stands"; pass=$((pass + 1))
else
  echo "FAIL  the first completion's date stands"
  grep '^merged:' work/tasks/task-0001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
