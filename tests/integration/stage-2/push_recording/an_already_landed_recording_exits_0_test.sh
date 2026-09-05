#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# A re-run of a job whose recording did land: the write is re-derived,
# committed, and dropped by the rebase as already applied. The branch
# carries it once and the run is green — the write is where it belongs,
# which is the whole question this script answers.
setup_intake
setup_racer

recording_commit work/tasks/task-0001.md "status: in-review"

# The same patch, landed by the run that won: byte-identical content, so
# the rebase recognises it and drops the duplicate.
racer_lands work/tasks/task-0001.md "queue: the first run landed it" <<'EOF'
status: in-review
EOF

# Loud when the fixture's own push failed. Without this the race never
# happens: the file and the single landing below are what this run would
# produce on an empty branch, so both assertions pass over a world where
# nothing landed first and the case proves nothing. The racer's subject
# is the one thing the two worlds do not share.
check "the first run really landed it before this one" 0 \
  "queue: the first run landed it" \
  -- authority log -1 --format=%s main

check "a recording already on the branch is not a failure" 0 \
  "" \
  -- bash "$PUSH" main

check "the recording is on origin's main" 0 \
  "task-0001.md" \
  -- authority ls-tree --name-only main:work/tasks

landings() { authority log --oneline main -- work/tasks/task-0001.md | wc -l | tr -d ' '; }
check "and the branch carries it once" 0 \
  "1" \
  -- landings

finish
