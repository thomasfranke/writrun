#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# Two events touching one task's status line — an `opened` and a
# `ready_for_review` seconds apart. The sibling's write landed first and
# says something else, so the rebase cannot replay this one. It fails
# loudly, which is the point: what it must never do is leave conflict
# markers in the queue files the projection reads from disk. The abort
# puts the tree back on the recording commit, and none of the remaining
# attempts are spent — the same commit would meet the same conflict.
setup_intake
setup_racer
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"
RECORDING=$(git rev-parse HEAD)

racer_lands work/tasks/task-0001.md "queue: the sibling wrote first" <<'EOF'
status: in-progress
EOF

check "a conflicting rebase ends the run red" 1 \
  "conflicted" \
  -- spied bash "$PUSH" main

git_told_times "and never reaches the remote at all" 0 "push "

tree_state() {
  if [ -z "$(git status --porcelain)" ]; then echo clean; else git status --porcelain; fi
}
check "the tree is clean — no markers where the projection reads" 0 \
  "clean" \
  -- tree_state
check "and HEAD is still the recording commit" 0 \
  "$RECORDING" \
  -- git rev-parse HEAD

finish
