#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# The common case, and what it costs: no sibling lands, so the first
# attempt's rebase meets a branch that has not moved and the push
# succeeds. One pull — the one fetch an attempt pays — one push, and no
# fetch of the guard's own: the caller's half is checked against the
# remote-tracking ref the checkout already carries.
setup_intake
spy_git

recording_commit work/tasks/task-0001.md "status: in-review"

check "a first attempt that meets no race lands" 0 \
  "recorded on main (attempt 1 of 5)" \
  -- spied bash "$PUSH" main

check "the recording is on origin's main" 0 \
  "task-0001.md" \
  -- authority ls-tree --name-only main:work/tasks

git_told_times "one pull — the one fetch the attempt pays" 1 "pull "
git_told_times "one push" 1 "push "
git_told_times "and no fetch beside it" 0 "fetch"

finish
