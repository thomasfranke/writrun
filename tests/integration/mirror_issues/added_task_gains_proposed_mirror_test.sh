#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# Flow 1: an authoring PR opens with a new task. The mirror is created,
# born **proposed** — the PR may still close unmerged and take the mirror
# with it, so the queue does not hold this task yet.
setup_forge
added_task task-001 "Add search"
check "an added task is mirrored at open" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror is born proposed" \
  "POST repos/o/r/issues -f title=[TASK-001] Add search -f labels[]=writrun:task -f labels[]=status:proposed"
forge_told "the body carries this PR's ownership line" \
  "| Introduced by | #7 |"

finish
