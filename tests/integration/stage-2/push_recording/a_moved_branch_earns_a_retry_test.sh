#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# The race report-0023 recorded, reproduced without a sleep: the armed
# hook lands the racer's commit after the rebase and before the push,
# so the first push is refused by a branch that really moved. That
# movement earns the retry, and the second attempt rebases onto what
# landed and pushes again — an addition to the branch's history, never
# a replacement of it.
setup_intake
setup_racer
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"
arm_racer_hook 1

check "a push refused by a moved branch is retried and lands" 0 \
  "recorded on main (attempt 2 of 5)" \
  -- spied bash "$PUSH" main

git_told_times "two pushes: the refusal, then the landing" 2 "push "

check "the recording is on origin's main" 0 \
  "task-0001.md" \
  -- authority ls-tree --name-only main:work/tasks
check "and the racer's commit is still there — added, not replaced" 0 \
  "race-0.txt" \
  -- authority ls-tree --name-only main

finish
