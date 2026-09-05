#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# The caller composes and commits; this script only lands what it finds.
# Both refusals below are for a caller wired wrong — the failure
# distribution/checks.md says looks ordinary — and both must be heard
# before the remote is touched, never watched as a no-op reporting
# success.
setup_intake
spy_git

check "nothing committed is refused, not reported as landed" 3 \
  "nothing committed, nothing to land" \
  -- spied bash "$PUSH" main

recording_commit work/tasks/task-0001.md "status: in-review"
printf 'half-composed\n' > work/tasks/task-0002.md

check "a dirty tree is refused — the caller has not finished composing" 3 \
  "the working tree is dirty" \
  -- spied bash "$PUSH" main

git_told_times "and neither refusal touched the remote" 0 "push "
git_told_times "nor cost a fetch: the guard reads the ref already carried" 0 "pull "

finish
