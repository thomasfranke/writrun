#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A pull request that only edits a queue file claims nothing: the id it
# carries is already on the base branch, belonging to whoever put it there.
setup
stub_forge
forge_pr 9 modified work/tasks/task-0007-theirs.md
task_file task-0007 pending ""
commit_all
check "another pull request's modification is not a claim" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
