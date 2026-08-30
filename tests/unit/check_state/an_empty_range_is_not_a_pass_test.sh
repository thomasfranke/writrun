#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A range that selects no commits is not a change that moved nothing.
# Without branches — which is every project at level `tasks-and-specs` —
# `main...HEAD` is empty by construction, and printing OK there vouches
# for a lifecycle nothing read.
setup
git checkout -q main
task_file task-001 ready ""
commit_all

check "an empty range is refused, not passed" 3 "selects no commits" \
  -- bash "$CHECK_STATE" HEAD...HEAD
out=$(bash "$CHECK_STATE" HEAD...HEAD 2>&1 || true)
if printf '%s' "$out" | grep -q "no forbidden lifecycle transition"; then
  echo "FAIL  and never reports a clean lifecycle"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
else
  echo "ok    and never reports a clean lifecycle"; pass=$((pass + 1))
fi

# A range with commits but no queue change is an honest pass, unchanged.
# `setup` left a `feature` branch behind; going back to it and adding a
# commit is the ordinary shape this check runs in.
git checkout -q feature
printf 'unrelated\n' > docs/about.md
commit_all
check "a range with commits and no queue change still passes" 0 \
  "no forbidden lifecycle transition" \
  -- bash "$CHECK_STATE" main...HEAD

finish
