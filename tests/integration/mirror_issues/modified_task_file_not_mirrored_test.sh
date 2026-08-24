#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# Only a task the diff *adds* gains a mirror — an implementation PR
# modifies an existing task, and that is writrun progress's business.
setup_forge
pr_patch modified "work/tasks/task-001.md" <<'EOF'
@@ -2,1 +2,1 @@
-status: pending
+status: in-progress
EOF
check "a modified task mirrors nothing" 0 "" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no issue is created for it" \
  "POST repos/o/r/issues -f title="

finish
