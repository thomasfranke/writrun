#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A task can ship without a spec. Nothing is holding it, so it is
# approved by construction — the emptiness must read as ready, not as a
# missing approval.
setup_forge
base_task task-0005 ready ""
base_spec spec-0003 task-0005 approved
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] No specs of its own"
check "an empty spec_ref derives ready" 0 "task-0005 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md

finish
