#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The branch names a task but no mirror exists for it — nothing to move,
# and nothing is written.
setup_forge
export PR_HEAD_REF="task/007-cleanup"
check "a task without a mirror is a no-op" 0 "No mirrored Issue for task-007." \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_not_told "nothing is written" "-X PUT"
forge_not_told "and nothing is closed" "-X PATCH"

finish
