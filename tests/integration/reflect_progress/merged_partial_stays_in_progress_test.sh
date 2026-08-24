#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A PR can merge partial work — one spec of several. Closing the mirror
# then would hide a task still outstanding, so it stays open, in
# progress, for the lister to surface as work to resume.
setup_forge
export PR_STATE=closed PR_MERGED=true PR_HEAD_REF="spec/003-search"
base_spec spec-003 task-005
forge_issue 31 open "writrun:task,status:in-review" "task-005 — Search"
pr_patch modified "work/tasks/task-005.md" <<'EOF'
@@ -2,2 +2,2 @@
 id: task-005
-status: pending
+status: in-progress
EOF
check "a partial merge keeps the task outstanding" 0 \
  "task-005 merged but not completed — back to status:in-progress" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the mirror stays open, in progress" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:in-progress"
forge_not_told "and is not closed" \
  "-f state=closed"

finish
