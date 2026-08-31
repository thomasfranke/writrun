#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The merged close passes this pass two things: the specs the merge
# approved, and every task id the recording had in scope. The second is
# what reaches a task no approval names — one the merge created already
# resting where it belongs, whose mirror was minted bare seconds earlier
# and would otherwise wear no `status:` label at all.
setup_forge
base_task task-0007 ready ""
forge_issue 42 open "writrun:task" "[TASK-0007] Born ready"
check "a bare task id in scope resolves to its file" 0 "task-0007 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r task-0007
forge_told "and the mirror minted bare gains both labels it lacked" \
  "PUT repos/o/r/issues/42/labels -f labels[]=writrun:task -f labels[]=status:ready -f labels[]=origin:rule"

finish
