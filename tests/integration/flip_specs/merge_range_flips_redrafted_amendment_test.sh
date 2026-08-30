#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The amendment flow survives the move to a merge trigger: a spec the
# change returned approved→draft is assented to by the same merge, so it
# flips back and the net status on the base branch is unchanged.
setup
task_file task-0001 ready spec-0001
spec_file spec-0001 task-0001 approved
commit_all
git checkout -q main
git merge -q feature
git checkout -q feature
spec_file spec-0001 task-0001 draft
commit_all
git checkout -q main
git merge -q --squash feature
git commit -qm "squash: amend spec-0001"
merge=$(git rev-parse HEAD)
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/flip_approved_specs.sh" "${merge}~1...${merge}")
if printf '%s' "$out" | grep -q "approved work/specs/spec-0001.md" &&
   grep -q '^status: approved$' work/specs/spec-0001.md; then
  echo "ok    a merge flips a re-drafted amendment back"; pass=$((pass + 1))
else
  echo "FAIL  a merge flips a re-drafted amendment back"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
