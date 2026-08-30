#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A task with no spec names its branch after the task itself — the bare
# number form resolves without any spec file to go through.
setup_forge
export PR_HEAD_REF="task/007-cleanup"
forge_issue 22 open "writrun:task,status:ready" "task-007 — Cleanup"
check "a task-named branch resolves directly" 0 \
  "task-0007 → status:in-review (#7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "its mirror moves to in-review" \
  "PUT repos/o/r/issues/22/labels -f labels[]=writrun:task -f labels[]=status:in-review"

finish
