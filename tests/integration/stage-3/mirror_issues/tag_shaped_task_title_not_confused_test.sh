#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A task's own title may contain a bracketed, tag-shaped string. Only the
# prefix the machinery wrote names the task; what follows is the author's
# prose, carried into the mirror untouched — and never read back as an id.

# Minting: the prose survives, and the tag written is the task's own.
setup_forge
added_task task-002 "Reject [TASK-0001] in a body"
check "a tag-shaped string in the title is minted as prose" 0 \
  "Created issue for task-002" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the leading tag is the task's, the rest is text" \
  "-f title=[TASK-002] Reject [TASK-0001] in a body"

# Looking it back up: the leading tag resolves it. Were the trailing one
# read too, this mirror would answer to task-0001 as well.
setup_forge
added_task task-002 "Reject [TASK-0001] in a body"
forge_issue 12 open "writrun:task,status:backlog" "[TASK-002] Reject [TASK-0001] in a body"
check "and only the leading tag resolves the mirror" 0 "already mirrored" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no second mirror is minted" \
  "POST repos/o/r/issues -f title="

finish
