#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# One call per open pull request, and every one of them counts: the
# highest claimed id is the only thing the mint may sit above, and it can
# be on any of them.
setup
stub_forge
forge_pr 7 added work/tasks/task-0011-theirs.md
forge_pr 9 added work/tasks/task-0020-theirs.md
forge_pr 9 added work/specs/spec-0031-theirs.md
forge_pr 12 modified work/tasks/task-0004-theirs.md
check "every open pull request is folded in" 0 "every open pull request" \
  -- bash "$NEW_SH" task "Mine" --origin rule
if [ -f work/tasks/task-0021-mine.md ]; then
  echo "ok    and the mint clears the highest of them"; pass=$((pass + 1))
else
  echo "FAIL  and the mint clears the highest of them"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# A spec's numbering is its own: the tasks above say nothing about it.
check "a spec is minted against the spec ids" 0 "every open pull request" \
  -- bash "$NEW_SH" spec task-0021 "Theirs and mine"
if [ -f work/specs/spec-0032-theirs-and-mine.md ]; then
  echo "ok    above the highest spec any of them claims"; pass=$((pass + 1))
else
  echo "FAIL  above the highest spec any of them claims"
  ls work/specs | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
