#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A quoted value is valid YAML that a line-based reader returns quotes
# and all — every path comparison downstream would quietly miss.
setup
cat > work/tasks/task-001.md <<'EOF'
---
id: task-001
status: pending
blocked_reason: null
spec_ref: []
doc_ref: "product/chapter.md#scope"
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
queued: null
completed: null
merged: null
---

# A task with a quoted value
EOF
check "a quoted value is outside the contract" 1 "is quoted" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
