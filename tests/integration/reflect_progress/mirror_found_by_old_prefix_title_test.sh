#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A mirror minted before the rule still carries `task-NNNN — <title>`.
# Losing it to the lookup would not fail loudly — it would report "no
# mirrored Issue" and leave a live mirror frozen at whatever label it
# happened to hold.
setup_forge
export PR_HEAD_REF="task/0005-tag-titles"
export PR_TITLE="[TASK-0005] feat(mirror): something"
forge_issue 31 open "writrun:task,status:ready" "task-0005 — Title mirror Issues by task tag"
check "an old-form mirror is still found" 0 \
  "task-0005 → status:in-review (#7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the mirror reads in-review" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:in-review"

finish
