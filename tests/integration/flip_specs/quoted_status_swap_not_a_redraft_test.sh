#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A body edit that swaps quoted status lines puts an amendment's exact
# diff lines into the change — but the front matter never moved, so
# nothing qualifies for a flip.
setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
printf 'status: approved\n' >> work/specs/spec-001.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
sed '$d' work/specs/spec-001.md > work/specs/spec-001.md.tmp \
  && mv work/specs/spec-001.md.tmp work/specs/spec-001.md
printf 'status: draft\n' >> work/specs/spec-001.md
commit_all
out=$(bash "$CI_SCRIPTS/flip_approved_specs.sh" main...HEAD)
fm_status=$(sed -n '2,/^---$/p' work/specs/spec-001.md | sed -n 's/^status: *//p')
if [ -z "$out" ] && [ "$fm_status" = "approved" ]; then
  echo "ok    a quoted status swap is not a redraft"; pass=$((pass + 1))
else
  echo "FAIL  a quoted status swap is not a redraft"
  printf '%s\n' "$out" | sed 's/^/      | /'
  grep -n 'status:' work/specs/spec-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
