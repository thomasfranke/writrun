#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# The rebase conflicts and the abort itself fails. What must never
# follow is the run claiming it aborted back to the recording commit: the
# queue files still carry markers, and the mirror steps that run after a
# failed recording parse those files from disk. The claim is checked, so
# it is either true or the run says so.
setup_intake
setup_racer
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"

racer_lands work/tasks/task-0001.md "queue: the sibling wrote first" <<'EOF'
status: in-progress
EOF

git_fails_for rebase 1 "fatal: could not abort"

CODE=0
spied bash "$PUSH" main > "$WORK/out" 2>&1 || CODE=$?
replay() { cat "$WORK/out"; return "$CODE"; }

check "an abort that failed ends the run red" 1 \
  "the abort failed" \
  -- replay

refute "and never claims the recording commit was restored" \
  "aborted back to the recording commit" -- replay

git_told_times "and nothing reached the remote" 0 "push "

unmerged() { git diff --name-only --diff-filter=U; }
check "the tree really is the one the message names" 0 \
  "work/tasks/task-0001.md" \
  -- unmerged

finish
