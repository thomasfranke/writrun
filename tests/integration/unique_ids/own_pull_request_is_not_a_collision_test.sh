#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The pull request being checked is in the forge's list of open ones like
# any other. Its own additions are the ones under examination — reading
# them back as somebody else's claim would fail every change that adds a
# queue file.
setup
stub_forge
forge_pr 7 added work/tasks/task-0007.md
task_file task-0007 pending ""
commit_all
check "a pull request does not collide with itself" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
