#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# A connection reset on the push side. It leaves the tip exactly where
# it was, because nothing arrived — so the movement test cannot see it,
# and reading that stillness as a ruleset blames a token, a check or a
# protected branch, none of which are true. A push that never completed
# does not arm the movement test at all.
setup_intake
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"
remote_unreachable_for push 1

CODE=0
spied bash "$PUSH" main > "$WORK/out" 2>&1 || CODE=$?
replay() { cat "$WORK/out"; return "$CODE"; }

check "a push that never completed earns the next attempt" 0 \
  "recorded on main (attempt 2 of 5)" \
  -- replay

refute "and the unmoved tip is not read as a refusal" "unmoved" -- replay

git_told_times "two pushes: the one that never arrived, then the one that did" 2 "push "

check "the recording is on origin's main" 0 \
  "task-0001.md" \
  -- authority ls-tree --name-only main:work/tasks

finish
