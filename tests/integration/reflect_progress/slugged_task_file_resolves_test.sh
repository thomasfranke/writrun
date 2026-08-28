#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The branch names a number; the task file carries the id. A subject slug
# in the filename is not identity, so resolution must find the file
# through the number — and the mirror through the id it holds.
setup_forge
export PR_HEAD_REF="task/0007-cleanup"
cat > work/tasks/task-0007-tidy-the-queue.md <<'EOF'
---
id: task-0007
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

# Tidy the queue
EOF
forge_issue 22 open "writrun:task,status:ready" "task-0007 — Tidy the queue"
check "a slugged task file resolves from its branch" 0 \
  "task-0007 → status:in-review (#7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "its mirror moves to in-review" \
  "PUT repos/o/r/issues/22/labels -f labels[]=writrun:task -f labels[]=status:in-review"

finish
