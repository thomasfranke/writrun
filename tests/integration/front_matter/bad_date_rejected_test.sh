#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `created` is a sort key of the selection algorithm — a date in any
# other shape missorts every tie silently.
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
milestone: null
created: 23/08/2026
completed: null
---

# A task with a local-format date
EOF
check "a malformed date is named" 1 "expected YYYY-MM-DDTHH:MM:SSZ" \
  -- bash "$CHECK_FRONT_MATTER"

finish
