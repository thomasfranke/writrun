#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The recording commit of the merge that approves a task's specs — or
# finds it has none to approve — moves it backlog -> ready in the same
# commit; an amendment regressing a spec moves it back.
setup
git checkout -q main
task_file task-001 backlog spec-001
spec_file spec-001 task-001 draft
task_file task-002 backlog ""
commit_all
spec_file spec-001 task-001 approved
commit_all

out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD)
printf '%s\n' "$out" | grep -q "task-001.md: backlog -> ready" \
  && { echo "ok    an approved spec settles its task to ready"; pass=$((pass+1)); } \
  || { echo "FAIL  an approved spec settles its task to ready"; printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail+1)); }

# task-002 was not in the range — untouched, even though empty-ref.
grep -qx "status: backlog" work/tasks/task-002.md \
  && { echo "ok    a task outside the range is not touched"; pass=$((pass+1)); } \
  || { echo "FAIL  a task outside the range is not touched"; fail=$((fail+1)); }

# The empty-ref task lands ready when its own merge brings it in.
git checkout -q main >/dev/null 2>&1 || true
setup
git checkout -q main
printf 'seed\n' > seed.txt
commit_all
task_file task-002 backlog ""
commit_all
check "an empty spec_ref settles to ready at its own merge" 0 "backlog -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD

# Regression: a merge returning the spec to draft moves ready back.
setup
git checkout -q main
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
commit_all
spec_file spec-001 task-001 draft
commit_all
check "an amendment regresses ready to backlog" 0 "ready -> backlog" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD

finish
