#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The pairing binds both ways: a reason on an unblocked task is a status
# disagreeing with itself — null otherwise, the schema says.
setup
cat > work/tasks/task-001.md <<'EOF'
---
id: task-001
status: pending
blocked_reason: upstream release still pending
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
completed: null
---

# A pending task carrying a blocked reason
EOF
check "a reason without blocked is named" 1 "null unless blocked" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
