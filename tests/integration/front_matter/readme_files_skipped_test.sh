#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The queue folders carry READMEs for people; they are prose, not queue
# entries, and owe the contract nothing.
setup
printf '# work/tasks — the queue\n\nProse, not front matter.\n' > work/tasks/README.md
printf '# work/specs — the detail\n\nProse, not front matter.\n' > work/specs/README.md
task_file task-001 pending ""
check "READMEs are not queue entries" 0 "all canonical" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
