#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# When the forge cannot say whether a survivor works the task, the task
# lands: a queue that briefly forgets a survivor heals at that
# survivor's next event; a task stranded in-flight heals never.
setup
task_file task-0001 in-progress "" null somebody

export PR_HEAD_REF="task/0001-work" PR_AUTHOR=somebody PR_DRAFT=true PR_MERGED=false
export GH_TOKEN="" GH_REPO="o/r"
check "closed unmerged with no forge answer lands the task" 0 "in-progress -> ready" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
unset PR_HEAD_REF PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
