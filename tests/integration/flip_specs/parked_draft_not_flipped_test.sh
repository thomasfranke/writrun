#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A spec deliberately parked in draft on main, merely edited by the PR,
# earns nothing from the PR's approval.
setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'still being shaped\n' >> work/specs/spec-001.md
commit_all
out=$(bash "$CI_SCRIPTS/flip_approved_specs.sh" main...HEAD)
if [ -z "$out" ] && grep -q '^status: draft$' work/specs/spec-001.md; then
  echo "ok    a spec parked in draft on main is not flipped by an edit"; pass=$((pass + 1))
else
  echo "FAIL  a spec parked in draft on main is not flipped by an edit"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
