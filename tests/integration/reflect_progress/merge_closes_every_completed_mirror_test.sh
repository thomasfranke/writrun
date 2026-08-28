#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A merge completing several carried tasks closes each one's mirror —
# and completion is judged per task, so one carried task finishing does
# not close a sibling still outstanding.
setup_forge
export PR_HEAD_REF="task/0004-two-at-once"
export PR_TITLE="[TASK-0004][TASK-0005] feat(mirror): reconcile in one pass"
export PR_STATE=closed PR_MERGED=true
forge_issue 22 open "writrun:task,status:in-review" "task-0004 — First"
forge_issue 23 open "writrun:task,status:in-review" "task-0005 — Second"
pr_patch modified "work/tasks/task-0004.md" <<'EOF'
@@ -1,3 +1,3 @@
-status: in-progress
+status: completed
EOF
pr_patch modified "work/tasks/task-0005.md" <<'EOF'
@@ -1,3 +1,3 @@
 status: in-progress
EOF
check "the completed task's mirror closes" 0 "task-0004 completed — Issue #22 closed" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the outstanding sibling goes back to in-progress" \
  "PUT repos/o/r/issues/23/labels -f labels[]=writrun:task -f labels[]=status:in-progress"
forge_not_told "and it is not closed" "issues/23 -f state=closed"

finish
