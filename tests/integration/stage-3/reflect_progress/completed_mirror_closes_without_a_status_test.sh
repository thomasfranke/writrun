#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# An issue closed as completed reading `status:in-review` says the
# maintainer is still the blocker. That is not stale, it is false — the
# close and its reason are the terminal state.
setup_forge
export PR_STATE=closed PR_MERGED=false PR_HEAD_REF="task/0005-done"
export PR_TITLE="[TASK-0005] feat(x): finish it"
export PR_MERGED=true
base_spec spec-0003 task-0005
forge_issue 31 open "writrun:task,status:in-review" "[TASK-0005] Finished"
pr_patch modified "work/tasks/task-0005.md" <<'PATCH'
@@ -1,4 +1,4 @@
-status: in-progress
+completed: 2026-08-29T10:00:00Z
PATCH
check "a completed task closes its mirror" 0 "completed — Issue #31 closed" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the status label is stripped as part of closing" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task"
forge_not_told "and no status label survives" \
  "-f labels[]=status:"
forge_told "the issue closes as completed" \
  "PATCH repos/o/r/issues/31 -f state=closed -f state_reason=completed"

finish
