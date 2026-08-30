#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# Most merges approve nothing. They must not pay a round trip to the
# forge, and must not relabel anything on the way past.
setup_forge
base_task task-0005 pending spec-0003
base_spec spec-0003 task-0005 approved
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] Untouched"
check "a merge recording no approval derives nothing" 0 "no label to re-derive" \
  -- bash "$REDERIVE_LABELS" o/r
forge_untouched "and the forge was never consulted"

finish
