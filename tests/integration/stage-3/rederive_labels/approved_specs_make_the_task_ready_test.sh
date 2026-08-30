#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# `status:ready` used to be unreachable. The mirror derived it from the
# spec statuses in the merged PR's diff, where they are still `draft` —
# because that same merge is what approves them. Reading the queue after
# the flip is the only input that reflects what the merge *caused*.
setup_forge
base_task task-0005 ready spec-0003
base_spec spec-0003 task-0005 approved
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] Now approved"
check "an approved spec makes its task ready" 0 "task-0005 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md
forge_told "the mirror reads ready" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:ready"

finish
