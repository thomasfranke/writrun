#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The merge carried the task to completed — the diff says so with an
# actual `+completed: 2026-08-29T10:00:00Z` line — so the mirror closes, done.
setup_forge
export PR_STATE=closed PR_MERGED=true PR_HEAD_REF="spec/003-search"
base_spec spec-003 task-005
forge_issue 31 open "writrun:task,status:in-review" "task-005 — Search"
pr_patch modified "work/tasks/task-005.md" <<'EOF'
@@ -2,2 +2,2 @@
 id: task-005
-status: in-progress
+completed: 2026-08-29T10:00:00Z
EOF
check "a completing merge closes the mirror" 0 \
  "task-005 completed — Issue #31 closed" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the mirror closes as completed" \
  "PATCH repos/o/r/issues/31 -f state=closed -f state_reason=completed"

finish
