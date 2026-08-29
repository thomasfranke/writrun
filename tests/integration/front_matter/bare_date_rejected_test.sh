#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The shape the queue held before this rule. It has to be rejected, not
# tolerated: a bare date cannot order two entries made the same day, and
# `created` is the selection algorithm's second sort key — so on a busy
# day it was sorting by id and pretending otherwise.
setup
cat > work/tasks/task-001.md <<'TASK'
---
id: task-001
status: pending
blocked_reason: null
spec_ref: []
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
completed: null
---

# A task carrying the old shape
TASK
check "a bare date is no longer canonical" 1 "expected YYYY-MM-DDTHH:MM:SSZ" \
  -- bash "$CHECK_FRONT_MATTER"

finish
