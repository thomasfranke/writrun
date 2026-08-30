#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The head branch name is a fork's to choose — validated as data, and a
# branch naming no task exits without writing.
setup
task_file task-0001 ready ""

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="docs/some-rule"
check "a docs branch records nothing" 0 "names no task branch" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
export PR_HEAD_REF='$(rm -rf /)'
check "a hostile branch name is data, not code" 0 "names no task branch" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
grep -qx "status: ready" work/tasks/task-0001.md \
  && { echo "ok    and the queue never moved"; pass=$((pass+1)); } \
  || { echo "FAIL  and the queue never moved"; fail=$((fail+1)); }
unset PR_HEAD_REF PR_AUTHOR PR_DRAFT PR_MERGED

finish
