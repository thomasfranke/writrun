#!/usr/bin/env bash
# The queue file cannot see a draft opened seconds ago, nor an amendment
# still riding an open pull request. The gate makes the same two forge
# reads the lister makes — one weaker than the lister it re-checks would
# hand back the task the lister held.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
commit_all
forge_open_pr 7 task/0001-something "[TASK-0001] Already going" someone
check "a task already in flight is refused" 1 "already in flight on pull request #7" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"
no_branch_cut "and no branch was cut" "task/0001-task-001"

take_setup
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 approved
commit_all
forge_open_pr 9 queue/amend-spec-0001 "[Chore][Specs] Amend spec-0001" someone
forge_pr 9 modified work/specs/spec-001.md
check "an amendment on one of its specs suspends the take" 1 "pull request #9 amends spec-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"

take_setup
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 approved
commit_all
forge_open_pr 9 docs/unrelated "[Docs] Something else" someone
forge_pr 9 modified docs/product/chapter.md
check "an unrelated open pull request holds nothing" 0 "draft pull request open" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it"

finish
