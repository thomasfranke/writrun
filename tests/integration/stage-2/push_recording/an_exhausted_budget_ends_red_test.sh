#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# A branch that never stops moving: the hook lands a racer commit before
# every push, so every attempt is refused by a branch that really moved
# and every refusal earns the next attempt. The budget runs out, and
# what must never happen is exit 0 over a queue nothing was written to.
# The message names the branch and the attempts spent, which is what
# separates this by eye from the unmoved refusal beside it.
setup_intake
setup_racer
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"
arm_racer_hook

# One run, read twice: the assertions below are about a single spent
# budget, and a second invocation would spend a second one — five more
# pushes under the same spy, and a push count that proves nothing.
CODE=0
spied bash "$PUSH" main > "$WORK/out" 2>&1 || CODE=$?
replay() { cat "$WORK/out"; return "$CODE"; }

check "a branch that outruns the budget ends the run red" 1 \
  "refused on all 5 attempts" \
  -- replay

check "and the message names the recovery" 1 \
  "re-running the job re-derives the same write" \
  -- replay

git_told_times "exactly five pushes, one per attempt" 5 "push "

finish
