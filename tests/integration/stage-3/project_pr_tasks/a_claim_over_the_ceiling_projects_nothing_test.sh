#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A relabelling pass over dozens of mirrors is the same refused claim
# wearing Stage 3's clothes: over the ceiling the projection writes
# nothing, reaches no forge at all, and goes red — the same message
# shape the in-flight writer prints (spec-0069).
setup_forge
base_task task-0001 in-progress ""
base_task task-0009 ready ""
forge_issue 31 open "writrun:task,status:in-progress" "[TASK-0001] The work"

export PR_HEAD_REF="task/0001-the-work"
export PR_TITLE="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009][Feat][Ci] Everything at once"

check "nine distinct tasks project nothing" 1 "claim 9 distinct tasks" \
  -- bash "$PROJECT_PR" o/r
forge_untouched "and not one call reaches the forge"
unset PR_HEAD_REF PR_TITLE

finish
