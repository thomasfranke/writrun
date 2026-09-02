#!/usr/bin/env bash
# Resuming is not taking. A branch that already exists — locally or on
# the forge — is named and the run stops; the one carve-out is a local
# branch with no upstream and no pull request, which is the leftover of
# an interrupted take and what --resume finishes.
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

finish
