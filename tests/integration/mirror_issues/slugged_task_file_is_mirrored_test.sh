#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The mirror follows the task file whatever its name: a queue file named
# <id>-<subject> is the same task as a bare-id one, and an unmirrored
# task is the one failure this script exists to prevent.
setup_forge
pr_file added "work/tasks/task-0004-queue-file-names.md" <<'EOF'
---
id: task-0004
status: pending
blocked_reason: null
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-28
completed: null
---

# Name task and spec files by id and subject
EOF
check "a slugged task file is mirrored at open" 0 "Created issue for task-0004" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror is born pending" \
  "-f labels[]=writrun:task -f labels[]=status:pending"

finish
