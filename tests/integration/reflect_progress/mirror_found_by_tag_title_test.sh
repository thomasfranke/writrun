#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The mirror lookup moved with the title: a mirror titled by its tag is
# the one this PR's task owns, and it moves like any other.
setup_forge
export PR_HEAD_REF="task/0005-tag-titles"
export PR_TITLE="[TASK-0005] feat(mirror): resolve every task a PR title tags"
forge_issue 31 open "writrun:task,status:ready" "[TASK-0005] Title mirror Issues by task tag"
check "a tag-titled mirror is found and moved" 0 \
  "task-0005 → status:in-review (#7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the mirror reads in-review" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:in-review"

finish
