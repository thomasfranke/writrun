#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The catch-up path: a merge finds a task with no mirror at all, because
# the open event was missed or deferred. The queue holds the task now, so
# `proposed` would say the opposite of what the merge just made true —
# and so would any other status this pass could invent, because the file
# is the truth from here and the projection is what reads it. It is minted
# with the two labels that are facts about the task, and nothing else.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-001 "Caught up at merge" spec-001
added_spec spec-001 task-001 draft
check "a merge creates the mirror it never had" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "carrying the mirror label and the origin" \
  "-f labels[]=writrun:task -f labels[]=origin:rule"
forge_not_told "and never proposed" \
  "-f labels[]=status:proposed"
forge_not_told "and no status at all — that is the projection's to write" \
  "labels[]=status:"

finish
