#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The tree and the history are one branch's view. An open pull request
# holds a number no branch here can see — it may be a fork's — and two
# branches cut from the same main both minting the next one is the whole
# reason the rule reaches past the checkout.
setup
stub_forge
forge_pr 9 added work/tasks/task-0004-theirs.md
check "the mint reaches past this checkout" 0 "every open pull request" \
  -- bash "$NEW_SH" task "Mine" --origin rule
if [ -f work/tasks/task-0005-mine.md ]; then
  echo "ok    and lands above the id that pull request claims"; pass=$((pass + 1))
else
  echo "FAIL  and lands above the id that pull request claims"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
