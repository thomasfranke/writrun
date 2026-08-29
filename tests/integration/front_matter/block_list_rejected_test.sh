#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A block list is valid YAML and invisible to a line-based reader: the
# task would look spec-less — ready without its approval gate. The exact
# silent failure this check turns into a loud one.
setup
cat > work/tasks/task-001.md <<'EOF'
---
id: task-001
status: pending
blocked_reason: null
spec_ref:
  - spec-001
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
queued: null
completed: null
merged: null
---

# A task with a block list
EOF
check "a block list is outside the contract" 1 "spec_ref" \
  -- bash "$CHECK_FRONT_MATTER"

finish
