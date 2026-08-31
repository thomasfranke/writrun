#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# How a task came to exist is part of the contract, not an optional
# annotation: a file without `origin` is a task whose birth nothing
# records, and no later event can recover it.
setup
cat > work/tasks/task-001.md <<'TASK'
---
id: task-001
status: ready
blocked_reason: null
taken_by: null
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23T00:00:00Z
queued: null
completed: null
merged: null
---

# A task missing its origin field
TASK
check "an omitted origin is named" 1 "origin" \
  -- bash "$CHECK_FRONT_MATTER"

finish
