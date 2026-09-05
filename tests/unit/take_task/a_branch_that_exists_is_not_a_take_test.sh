#!/usr/bin/env bash
# Resuming is not taking. A branch that already exists — locally or on
# the forge — is named and the run stops; the one carve-out is a local
# branch with no pull request, which is the leftover of an interrupted
# take and what --resume finishes, wherever the branch got to. It used
# to be narrower — "no upstream and no pull request" — until report-0026
# showed the push arming the very guard the printed recovery then hit.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
commit_all
publish_main
git branch task/0001-mirror-lag main
check "an existing local branch is refused" 1 "already exists locally" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
forge_untouched "and the forge was never called"

take_setup
task_file task-001 ready ""
commit_all
publish_main
git branch task/0001-mirror-lag main
git push -q origin task/0001-mirror-lag
git branch -D task/0001-mirror-lag >/dev/null
git fetch -q origin
check "one that exists only on the forge is refused" 1 "already exists on the forge" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag

take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main && git switch -q main
check "--resume finishes an interrupted take" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if git -C "$WORK/origin.git" rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null \
   && grep -q 'pr create --draft' "$FORGE_LOG"; then
  echo "ok    with the push and the pull request, and no second branch"; pass=$((pass + 1))
else
  echo "FAIL  with the push and the pull request, and no second branch"; fail=$((fail + 1))
fi

check "--resume with nothing to finish is refused" 1 "does not exist locally" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug nothing-here --resume

# The half the act can actually leave behind: pushed, and no pull
# request anywhere. The resume finishes it — same branch, same commit,
# the push a no-op and the draft opened.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
check "--resume finishes a branch already on the forge" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if grep -q 'pr create --draft' "$FORGE_LOG" \
   && [ "$(git rev-list --count origin/main..task/0001-mirror-lag)" = 1 ] \
   && [ "$(git -C "$WORK/origin.git" rev-list --count main..task/0001-mirror-lag)" = 1 ]; then
  echo "ok    with the draft open, no second branch and no second commit"; pass=$((pass + 1))
else
  echo "FAIL  with the draft open, no second branch and no second commit"; fail=$((fail + 1))
fi

# A pull request that already carries the task is the act completed:
# what refuses the rerun is the forge read, not the branch's location.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_open_pr 7 task/0001-mirror-lag "[TASK-0001] feat(ci): take it" alice
check "a resume over a task in flight is refused, naming the pull request" 1 \
  "already in flight on pull request #7 (by @alice)" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume

# A closed pull request means the flight ended and the task went back to
# ready: finishing the branch now would open a second draft over a base
# as old as the interruption. An ended flight is never resumed.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_closed_pr 9 task/0001-mirror-lag
check "a resume over an ended flight is refused, naming the closed pull request" 1 \
  "pull request #9 carried task/0001-mirror-lag and is closed" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if grep -q 'pr create' "$FORGE_LOG"; then
  echo "FAIL  and nothing was opened"; fail=$((fail + 1))
else
  echo "ok    and nothing was opened"; pass=$((pass + 1))
fi
if [ "$(git -C "$WORK/origin.git" rev-list --count main..task/0001-mirror-lag)" = 1 ] \
   && [ "$(git rev-parse task/0001-mirror-lag)" = "$(git -C "$WORK/origin.git" rev-parse task/0001-mirror-lag)" ]; then
  echo "ok    and nothing was pushed"; pass=$((pass + 1))
else
  echo "FAIL  and nothing was pushed"; fail=$((fail + 1))
fi

finish
