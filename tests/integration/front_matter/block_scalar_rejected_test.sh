#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A folded scalar puts the real value on continuation lines no reader
# sees — the lister would show a blocked task with no reason at all.
setup
cat > work/tasks/task-001.md <<'EOF'
---
id: task-001
status: blocked
blocked_reason: >
  waiting on an upstream release
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
queued: null
completed: null
merged: null
---

# A task with a folded scalar
EOF
check "a block scalar is outside the contract" 1 "block scalar" \
  -- bash "$CHECK_FRONT_MATTER"

finish
