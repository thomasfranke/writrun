#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The forge half is best-effort; the base-branch half is not. Losing the
# network must not turn a collision that git alone can see into a pass.
setup
stub_forge
task_file task-0007 pending ""
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
cp work/tasks/task-0007.md work/tasks/task-0007-again.md
commit_all
forge_unavailable
check "no forge still catches a base-branch collision" 1 "COLLISION" \
  -- bash "$CI_SCRIPTS/check_unique_ids.sh" main...HEAD o/r 7

finish
