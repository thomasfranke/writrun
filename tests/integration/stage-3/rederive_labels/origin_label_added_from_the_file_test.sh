#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A mirror minted before the field existed carries no origin label. The
# next recording commit's relabelling pass adds it, once, from the stored
# field — the same source every other label here is derived from.
setup_forge
base_task task-0005 ready spec-0003 report
base_spec spec-0003 task-0005 approved
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] An older mirror"
check "the pass re-derives the status" 0 "task-0005 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md
forge_told "and adds the missing origin label from the file" \
  "-f labels[]=status:ready -f labels[]=origin:report"
forge_told "declaring it on first use" \
  "POST repos/o/r/labels -f name=origin:report"

finish
