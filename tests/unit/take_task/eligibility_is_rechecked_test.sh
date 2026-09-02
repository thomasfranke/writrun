#!/usr/bin/env bash
# The lister applied these filters when the session chose; the take
# applies them again, because between the two runs is however long the
# session took to decide. Each refusal names the filter that held.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 backlog "spec-001"
spec_file spec-001 task-001 draft
commit_all
check "a backlog task is refused" 1 "only a 'ready' task" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"
no_branch_cut "and no branch was cut" "task/0001-task-001"

take_setup
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 draft
commit_all
check "a spec still in draft is refused" 1 "not authorized work" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"

take_setup
task_file task-001 done ""
task_file task-002 ready ""
sed -i.bak 's/^depends_on: \[\]$/depends_on: [task-001]/' work/tasks/task-002.md
sed -i.bak 's/^status: done$/status: in-progress/' work/tasks/task-001.md
rm -f work/tasks/*.bak
commit_all
check "an open dependency is refused" 1 "waits on task-001" \
  -- bash "$TAKE_TASK" task-002 --title "feat(ci): take it"

take_setup
task_file task-001 ready "" "" "@someone"
commit_all
check "a task already taken is refused" 1 "already taken by @someone" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"

take_setup
task_file task-001 ready ""
commit_all
printf 'uncommitted\n' > stray.txt
check "a dirty working tree is refused" 1 "working tree is dirty" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"
rm -f stray.txt

take_setup
task_file task-001 ready ""
commit_all
check "an id resolving to nothing is refused" 1 "resolves '99'" \
  -- bash "$TAKE_TASK" 99 --title "feat(ci): take it"

finish
