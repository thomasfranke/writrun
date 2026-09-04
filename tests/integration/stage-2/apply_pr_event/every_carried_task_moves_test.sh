#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A branch name holds one id and a title holds every task the work
# carries, so the event's write reaches the whole carried set — the
# sequence report-0022 saw go half-recorded.
setup
task_file task-0003 ready ""
task_file task-0005 ready ""
task_file task-0009 ready ""

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="task/0003-update-command"
export PR_TITLE="[TASK-0003][TASK-0005][Feat][Cli] Ship the update command"
check "a draft opening on two tags moves the branch's task" 0 \
  "task-0003.md: ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
task_field "and the title's second task with it" task-0005 status in-progress
task_field "both taken by the pull request's author" task-0005 taken_by worker
task_field "a task neither route names is untouched" task-0009 status ready

# The branch's task is carried whether or not the title tags it.
setup
task_file task-0011 ready ""
task_file task-0012 ready ""

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="task/0011-the-work"
export PR_TITLE="[TASK-0012][Feat][Ci] Work the pair"
check "the tagged task moves though the branch is another's" 0 \
  "task-0012.md: ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
task_field "and the branch's own task moves untagged" task-0011 status in-progress

# One task named by both routes is one task.
setup
task_file task-0013 ready ""

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="task/0013-the-work"
export PR_TITLE="[TASK-0013][Feat][Ci] The work"
moves=$(bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened 2>&1 \
  | grep -c "task-0013.md: ready -> in-progress")
if [ "$moves" -eq 1 ]; then
  printf 'ok    %s\n' "branch and tag naming one task write it once"; pass=$((pass + 1))
else
  printf 'FAIL  %s\n      %s writes\n' "branch and tag naming one task write it once" "$moves"
  fail=$((fail + 1))
fi

# A tag naming a task that does not exist answers for itself and never
# abandons the tags after it.
setup
task_file task-0015 ready ""

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="task/0014-the-work"
export PR_TITLE="[TASK-0014][TASK-0015][Feat][Ci] The pair"
check "an id resolving to no file is named, not fatal" 0 \
  "task-14 resolves to no file" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
task_field "and the task after it still moves" task-0015 status in-progress
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED

finish
