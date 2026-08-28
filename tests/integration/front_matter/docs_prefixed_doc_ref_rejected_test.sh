#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# doc_ref is written relative to docs/ — a docs/ prefix doubles when the
# machinery resolves it, and the queue-impact guard would never match.
setup
cat > work/tasks/task-001.md <<'EOF'
---
id: task-001
status: pending
blocked_reason: null
spec_ref: []
doc_ref: docs/product/chapter.md#scope
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
completed: null
---

# A task with a docs/-prefixed reference
EOF
check "a docs/-prefixed doc_ref is named" 1 "relative to docs/" \
  -- bash "$CHECK_FRONT_MATTER"

finish
