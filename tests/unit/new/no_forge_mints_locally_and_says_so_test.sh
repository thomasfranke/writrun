#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Best-effort, not required: without a forge the generator behaves exactly
# as it always did — and names the view it actually had, because a number
# minted blind is the one that collides at somebody else's merge.
setup
stub_forge
forge_unavailable
check "no forge mints from the checkout, and says so" 0 "this checkout and its history only" \
  -- bash "$NEW_SH" task "First" --origin rule
if [ -f work/tasks/task-0001-first.md ]; then
  echo "ok    the local tree and history still answer"; pass=$((pass + 1))
else
  echo "FAIL  the local tree and history still answer"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
