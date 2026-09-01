#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `task_ref` is a list even with one element, because triage can split
# one finding into several tasks — and because a line-based reader sees a
# bare value and a block list as the same nothing. It is the only link
# between the two kinds, so a shape the reader cannot see is a link that
# silently does not exist.
setup
mkdir -p work/reports

bare_task_ref() {
  cat > work/reports/report-0001.md <<INNER
---
id: report-0001
status: tracked
task_ref: $1
doc_ref: null
created: 2026-08-22T00:00:00Z
triaged: 2026-08-22T01:00:00Z
---

# A triaged report
INNER
}

bare_task_ref '[task-0007]'
check "one element, written as a list, is canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

bare_task_ref 'task-0007'
check "the same id written bare is refused" 1 "must be an inline list" \
  -- bash "$CHECK_FRONT_MATTER"

bare_task_ref '[task-0007, spec-0007]'
check "and an item that is not a task id is named" 1 "is not a task id" \
  -- bash "$CHECK_FRONT_MATTER"

finish
