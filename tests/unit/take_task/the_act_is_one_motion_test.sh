#!/usr/bin/env bash
# The push and the opening are one act: a branch on the forge with no
# pull request is the hiding place the taking flow exists to close, so
# the pull request never precedes the push and the branch never stays
# behind on purpose.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 approved
commit_all
publish_main

check "the take succeeds" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag

if git -C "$WORK/origin.git" rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null; then
  echo "ok    the branch reached the remote"; pass=$((pass + 1))
else
  echo "FAIL  the branch reached the remote"; fail=$((fail + 1))
fi

if grep -q 'pr create --draft' "$FORGE_LOG"; then
  echo "ok    and a draft pull request was opened"; pass=$((pass + 1))
else
  echo "FAIL  and a draft pull request was opened"; sed 's/^/      | /' "$FORGE_LOG"; fail=$((fail + 1))
fi

if grep -q 'pr create .*--title \[TASK-0001\] feat(ci): take it' "$FORGE_LOG"; then
  echo "ok    titled with the task tag and the given summary"; pass=$((pass + 1))
else
  echo "FAIL  titled with the task tag and the given summary"; sed 's/^/      | /' "$FORGE_LOG"; fail=$((fail + 1))
fi

# The branch is cut from the fetched authority branch, never from
# whatever the session happened to have checked out. Its first commit is
# what the tip now is, so the parent is what the cut is read from.
if [ "$(git rev-parse HEAD^)" = "$(git rev-parse origin/main)" ]; then
  echo "ok    the branch is cut from origin/main"; pass=$((pass + 1))
else
  echo "FAIL  the branch is cut from origin/main"; fail=$((fail + 1))
fi

# The queue is not written here. The status line has one writer, and it
# is the machinery answering the draft this opened.
if git diff --quiet main -- work/tasks; then
  echo "ok    and the task file is untouched"; pass=$((pass + 1))
else
  echo "FAIL  and the task file is untouched"; fail=$((fail + 1))
fi

finish
