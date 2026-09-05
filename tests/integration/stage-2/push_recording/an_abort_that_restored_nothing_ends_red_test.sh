#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# The abort returns 0 and restores nothing. An exit status is a claim
# about the tree, not the tree itself, and the whole point of the abort
# is what the tree holds afterwards — so the tree is read before the run
# reports it restored.
setup_intake
setup_racer
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"

racer_lands work/tasks/task-0001.md "queue: the sibling wrote first" <<'EOF'
status: in-progress
EOF

git_noops_for rebase 1

CODE=0
spied bash "$PUSH" main > "$WORK/out" 2>&1 || CODE=$?
replay() { cat "$WORK/out"; return "$CODE"; }

check "an abort that left the markers ends the run red" 1 \
  "left the tree unclean" \
  -- replay

refute "and never claims the recording commit was restored" \
  "aborted back to the recording commit" -- replay

check "the run names the file the projection would have read" 1 \
  "work/tasks/task-0001.md" \
  -- replay

git_told_times "and nothing reached the remote" 0 "push "

finish
