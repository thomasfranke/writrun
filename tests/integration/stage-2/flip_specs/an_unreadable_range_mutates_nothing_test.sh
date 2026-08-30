#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The dangerous one: it mutates, and it otherwise always exits 0. A
# swallowed failure here does not merely misreport — it records no
# approval at all, silently, on a merge that granted one.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 draft
commit_all

check "an unreadable range is refused, not treated as no specs" 3 "fatal:" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/flip_approved_specs.sh" nosuchref...HEAD
if grep -qx 'status: draft' work/specs/spec-001.md; then
  echo "ok    and nothing was mutated"; pass=$((pass + 1))
else
  echo "FAIL  and nothing was mutated"
  grep '^status:' work/specs/spec-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# A readable range still flips exactly as it did.
bash "$CI_SCRIPTS/stage-2-pull-requests/flip_approved_specs.sh" main...HEAD >/dev/null
if grep -qx 'status: approved' work/specs/spec-001.md; then
  echo "ok    and a readable range still flips"; pass=$((pass + 1))
else
  echo "FAIL  and a readable range still flips"; fail=$((fail + 1))
fi

finish
