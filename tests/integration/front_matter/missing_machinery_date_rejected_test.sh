#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The machinery's two dates are part of the contract, not an optional
# extra a stamping workflow adds later: a reader sees the whole shape
# without knowing which fields exist, and stamp_task_dates.sh writes into
# a field rather than inventing one.
setup
cat > work/tasks/task-001.md <<'EOF2'
---
id: task-001
status: pending
blocked_reason: null
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23T00:00:00Z
completed: null
merged: null
---

# A task missing its queued field
EOF2
check "a task without queued is malformed" 1 "queued" \
  -- bash "$CHECK_FRONT_MATTER"

sed -i.bak 's/^merged: null$/queued: null/' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "and one without merged is too" 1 "merged" \
  -- bash "$CHECK_FRONT_MATTER"

finish
