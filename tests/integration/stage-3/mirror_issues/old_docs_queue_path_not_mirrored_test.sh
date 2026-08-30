#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Regression: the queue lives in work/, and the mirror must read it there.
# When the queue moved out of docs/, the inline-YAML version of this logic
# kept matching docs/tasks/ — a mirror that would never fire again, and no
# test could say so. A task file under the old path is just a doc now.
setup_forge
pr_file added "docs/tasks/task-001.md" <<'EOF'
---
id: task-001
---

# A file where the queue used to live
EOF
added_task task-002 "The real queue entry"
check "the work/ path is the queue" 0 "Created issue for task-002" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "the old docs/ path is not mirrored" \
  "-f title=[TASK-001]"
forge_told "the work/ path is mirrored" \
  "-f title=[TASK-002] The real queue entry"

finish
