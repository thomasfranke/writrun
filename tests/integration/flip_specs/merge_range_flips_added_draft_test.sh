#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The assenting act is the merge, so the range the workflow passes is
# derived from the merge commit — never from a head branch the merge may
# already have deleted, and whose commits a squash merge never puts on
# the base at all.
setup
task_file task-0001 pending spec-0001
spec_file spec-0001 task-0001 draft
commit_all
git checkout -q main
git merge -q --squash feature
git commit -qm "squash: add spec-0001"
merge=$(git rev-parse HEAD)
out=$(bash "$CI_SCRIPTS/pull-requests/flip_approved_specs.sh" "${merge}~1...${merge}")
if printf '%s' "$out" | grep -q "approved work/specs/spec-0001.md" &&
   grep -q '^status: approved$' work/specs/spec-0001.md; then
  echo "ok    a merge flips the draft spec it carried"; pass=$((pass + 1))
else
  echo "FAIL  a merge flips the draft spec it carried"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
