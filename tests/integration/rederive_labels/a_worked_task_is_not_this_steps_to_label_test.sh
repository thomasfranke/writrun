#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The file is the truth: the machinery writes in-flight states onto the
# authority branch as their forge events land, so the label projects the
# stored status one to one — in-progress included
# (docs/product/stage-3-github-issues/labels.md).
setup_forge
base_task task-0005 in-progress spec-0003
base_spec spec-0003 task-0005 approved
forge_issue 31 open "writrun:task,status:ready" "[TASK-0005] Being worked"
check "a task under way is projected as under way" 0 "task-0005 → status:in-progress" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md
forge_told "the mirror follows the file" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:in-progress"

finish
