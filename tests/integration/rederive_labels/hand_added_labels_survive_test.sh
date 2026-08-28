#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# Only the `status:` label is the machinery's. Anything a project or a
# person put on the issue survives every move it makes.
setup_forge
base_task task-0005 pending spec-0003
base_spec spec-0003 task-0005 approved
forge_issue 31 open "writrun:task,status:pending,good first issue" "[TASK-0005] Labelled by hand"
check "re-derivation keeps foreign labels" 0 "task-0005 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md
forge_told "the hand-added label is carried through" \
  "-f labels[]=writrun:task -f labels[]=good first issue -f labels[]=status:ready"

finish
