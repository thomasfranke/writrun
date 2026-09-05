#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# A network blip, a forge 500, a proxy timeout: the attempt's pull never
# reaches the branch, so nothing is rebased and nothing conflicts. The
# verdict that must never be reached here is "conflicted" — it is the
# one that spends none of the remaining attempts, and it would cost the
# recording to the class a second attempt clears for free while sending
# the operator hunting a conflict that never existed.
setup_intake
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"
remote_unreachable_for pull 1

# One run, read twice: the injection fires once, so a second invocation
# would meet a reachable remote and prove something else.
CODE=0
spied bash "$PUSH" main > "$WORK/out" 2>&1 || CODE=$?
replay() { cat "$WORK/out"; return "$CODE"; }

check "a pull that never reached the branch earns the next attempt" 0 \
  "recorded on main (attempt 2 of 5)" \
  -- replay

refute "and is never called a conflict" "conflicted" -- replay
refute "nor aborts a rebase that never started" "no rebase in progress" -- replay

git_told_times "two pulls: the one that never arrived, then the one that did" 2 "pull "
git_told_times "one push — the attempt no false conflict took away" 1 "push "

check "the recording is on origin's main" 0 \
  "task-0001.md" \
  -- authority ls-tree --name-only main:work/tasks

finish
