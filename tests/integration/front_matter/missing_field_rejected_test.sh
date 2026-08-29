#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Every field is present even when null — an omitted field and an
# explicit null are not the same statement to a reader or a script.
setup
cat > work/tasks/task-001.md <<'EOF'
---
id: task-001
status: pending
blocked_reason: null
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
created: 2026-08-23
completed: null
---

# A task missing its milestone field
EOF
check "an omitted field is named" 1 "milestone" \
  -- bash "$CHECK_FRONT_MATTER"

finish
