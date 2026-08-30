#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# One derivation: the mirror restates the queue file the Stage-2
# recording just wrote — never a second answer from the event's own
# fields (the retired reflect_progress.sh's failure mode).
setup_forge
base_task task-0007 in-progress spec-0003 null worker
base_spec spec-0003 task-0007 approved
forge_issue 31 open "writrun:task,status:ready" "[TASK-0007] Being worked"
export PR_HEAD_REF="task/0007-work" PR_TITLE="[TASK-0007] feat: work"
check "the mirror is projected from the file" 0 "task-7 → status:in-progress" \
  -- bash "$PROJECT_PR" o/r
forge_told "and restates it one to one" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:in-progress"
unset PR_HEAD_REF PR_TITLE

# A pull request naming no task projects nothing, and that is not an
# error.
export PR_HEAD_REF="docs/some-rule" PR_TITLE="docs: a rule"
check "no task named, nothing projected" 0 "names no task — nothing to project" \
  -- bash "$PROJECT_PR" o/r
unset PR_HEAD_REF PR_TITLE

# Title tags reach every carried task, deduplicated with the branch's.
setup_forge
base_task task-0007 in-review spec-0003 null worker
base_spec spec-0003 task-0007 approved
base_task task-0008 ready ""
forge_issue 31 open "writrun:task,status:in-progress" "[TASK-0007] Being worked"
forge_issue 32 open "writrun:task,status:backlog" "[TASK-0008] Carried along"
export PR_HEAD_REF="task/0007-work" PR_TITLE="[TASK-0007][TASK-0008] feat: both"
out=$(bash "$PROJECT_PR" o/r)
if printf '%s' "$out" | grep -q "task-7 → status:in-review" \
  && printf '%s' "$out" | grep -q "task-8 → status:ready"; then
  echo "ok    every carried task is projected once"; pass=$((pass+1))
else
  echo "FAIL  every carried task is projected once"; printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail+1))
fi
unset PR_HEAD_REF PR_TITLE

finish
