#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The exit code is what a caller reads to decide whether to retry: 3 says
# "you called me wrong", 1 says "the claim was too big". With the ceiling
# refusal standing first, an unknown event riding an over-ceiling title
# exited 1 and told the caller to retitle a pull request whose title was
# never the fault (spec-0077).
setup
task_file task-0001 ready ""

export PR_HEAD_REF="task/0001-the-work" PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export GH_TOKEN="" GH_REPO="o/r"

export PR_TITLE="[TASK-0001] The work"
check "an unknown event is a usage error" 3 "usage: apply_pr_event.sh" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" locked

export PR_TITLE="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009] Everything"
check "and still a usage error over the ceiling" 3 "usage: apply_pr_event.sh" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" locked
task_field "with nothing written either way" task-0001 status ready

# The names the script does know are unchanged by the guard.
export PR_TITLE="[TASK-0001] The work"
check "a known event still dispatches" 0 "ready -> in-progress" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened

unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
