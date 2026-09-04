#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# One task's failure never abandons the tasks after it — and never
# passes for them either. The caller commits whatever the tree holds, so
# a swallowed failure pushes a half-applied event under a green run, and
# the task that did not move stays `ready` with its work in flight: a
# state no later event of this pull request heals, because `ready` has no
# edge to `in-review`.
setup
task_file task-0003 ready ""
task_file task-0005 ready ""

# The write is `awk > file.tmp && mv`, so a directory in the temp file's
# place is a write that cannot happen. A read-only checkout, a full
# runner disk and a leftover .tmp all reach the caller as this does.
mkdir -p "work/tasks/task-0005.md.tmp"

export PR_AUTHOR=worker PR_DRAFT=true PR_MERGED=false
export PR_HEAD_REF="task/0003-the-work"
export PR_TITLE="[TASK-0003][TASK-0005][Feat][Ci] The pair"
check "a carried task's failed write exits non-zero" 1 "exited" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" opened
task_field "the task before it moved" task-0003 status in-progress
task_field "and the one that could not be written did not" task-0005 status ready
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED

finish
