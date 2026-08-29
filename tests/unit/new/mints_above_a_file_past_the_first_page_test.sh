#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The defect this exists for: the forge answers a pull request's file list
# one page at a time, and the queue file may sit on any page of it. A scan
# that reads the first page only sees a big pull request as if it added
# nothing — and mints an id that pull request already claims.
setup
stub_forge
forge_pr_filler 9 104
forge_pr 9 added work/tasks/task-0042-theirs.md
check "the mint reads past the first page" 0 "every open pull request" \
  -- bash "$NEW_SH" task "Mine"
if [ -f work/tasks/task-0043-mine.md ]; then
  echo "ok    and lands above an id claimed on a later page"; pass=$((pass + 1))
else
  echo "FAIL  and lands above an id claimed on a later page"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
