#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `Z` is the only spelling, and this is the load-bearing half of the
# rule. Every reader here is line-based, so a lexicographic sort of these
# strings is meant to be a chronological sort — an offset form keeps
# `sort` looking correct while being wrong for exactly the entries that
# crossed a timezone.
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
created: 2026-08-23T09:14:00+02:00
queued: null
completed: null
merged: null
---

# A task stamped with an offset
TASK
check "an offset is not Z, and is rejected" 1 "expected YYYY-MM-DDTHH:MM:SSZ" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
