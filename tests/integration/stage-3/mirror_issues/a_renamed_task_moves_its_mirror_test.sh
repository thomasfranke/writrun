#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The same for a task, whose loop excluded every status but `added` on
# the strength of a comment that said a task file only ever arrives that
# way. A renumber is the way it does not.
#
# The id is taken from the **filename** here, not from front matter: a
# pure rename carries the block unchanged, so it still names the id the
# file left, and the id a change claims is the one its path lands on.
setup_forge
mkdir -p work/tasks
cat > work/tasks/task-0001-take-task.md <<'TSK'
---
id: task-0001
status: ready
blocked_reason: null
spec_ref: []
doc_ref: null
origin: rule
priority: high
depends_on: []
milestone: null
created: 2026-08-23T00:00:00Z
queued: null
completed: null
merged: null
---

# Take needs a commit
TSK
pr_renamed work/tasks/task-0001-take-task.md work/tasks/task-0002-take-task.md
forge_issue 12 open "writrun:task,status:proposed" "[TASK-0001] Take needs a commit"

check "a renamed task is mirrored at the id it lands on" 0 \
  "Created issue for task-0002" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "carrying the fields the file it left still holds" \
  "POST repos/o/r/issues -f title=[TASK-0002] Take needs a commit"
forge_told "and the mirror of the id it vacated retires" \
  "PATCH repos/o/r/issues/12 -f state=closed -f state_reason=not_planned"

finish
