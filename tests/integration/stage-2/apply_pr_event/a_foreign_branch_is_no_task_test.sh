#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The head branch name and the title are both a fork's to write —
# validated as data, and a pull request that carries no task by either
# route exits without writing.
setup
task_file task-0001 ready ""

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="docs/some-rule" PR_TITLE="[Docs][Product] Some rule"
check "a docs branch under an untagged title records nothing" 0 "carry no task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
export PR_HEAD_REF='$(rm -rf /)' PR_TITLE='$(rm -rf /) [TASK-] `id`'
check "a hostile branch name and title are data, not code" 0 "carry no task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
grep -qx "status: ready" work/tasks/task-0001.md \
  && { echo "ok    and the queue never moved"; pass=$((pass+1)); } \
  || { echo "FAIL  and the queue never moved"; fail=$((fail+1)); }
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED

finish
