#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The other side of the forge read. A pull request that renames a file
# onto an id has claimed it as surely as one that added it there, and
# until that pull request merges it holds the id it renamed away from
# too — so only the destination is asked for, and it collides.
setup
stub_forge
forge_pr 9 renamed work/tasks/task-0007-theirs.md
task_file task-0007 ready ""
commit_all

check "an id another open pull request renames onto is rejected, named" 1 "#9" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
