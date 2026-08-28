#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The tag is uppercase by convention and the file id lowercase, and the
# two widths need not agree either — `[TASK-5]` and `task-0005` are the
# same task. Lookups map one to the other, on the number.
setup_forge
export PR_HEAD_REF="task/0005-tag-titles"
export PR_TITLE="[task-5] feat(mirror): lowercase tag, short width"
forge_issue 31 open "writrun:task,status:ready" "[TASK-0005] Title mirror Issues by task tag"
check "case and width do not separate a tag from its id" 0 \
  "status:in-review (#7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the mirror reads in-review" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:in-review"

finish
