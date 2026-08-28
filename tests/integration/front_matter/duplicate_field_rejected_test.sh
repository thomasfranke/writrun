#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# First-match readers take the first occurrence; a duplicated field
# makes the file say two things at once.
setup
cat > work/tasks/task-001.md <<'EOF'
---
id: task-001
status: pending
status: completed
blocked_reason: null
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
completed: null
---

# A task that says two things at once
EOF
check "a duplicated field is named" 1 "exactly once" \
  -- bash "$CHECK_FRONT_MATTER"

finish
