#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A forge that answers "nothing is open" is a complete answer, not a
# narrow one: the mint is the tree's and the history's alone, and the
# report says the whole queue was consulted.
setup
stub_forge
bash "$NEW_SH" task "First" --origin rule >/dev/null 2>&1
commit_all
check "an empty open list still mints from the tree" 0 "every open pull request" \
  -- bash "$NEW_SH" task "Second" --origin rule
if [ -f work/tasks/task-0002-second.md ]; then
  echo "ok    and takes the next id after the tree's"; pass=$((pass + 1))
else
  echo "FAIL  and takes the next id after the tree's"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
