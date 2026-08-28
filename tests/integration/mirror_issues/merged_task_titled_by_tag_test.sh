#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The mirror's title is the tag a pull request title carries, so one
# search for `[TASK-0004]` finds the task in the queue, in the PR, and in
# the mirror at once (docs/product/pipeline.md#flows-and-statuses).
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-0004 "Name queue files by id and subject"
check "a merged task gains its mirror" 0 "Created issue for task-0004 (ready)" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "titled by the tag, not the old prefix" \
  "-f title=[TASK-0004] Name queue files by id and subject"

finish
