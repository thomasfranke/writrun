#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A spec documenting this methodology quotes status lines at column 0 in
# its body. Editing such a quote from draft to approved puts the exact
# lines of a forbidden transition into the diff — but the front matter
# never moved, and only the front matter is the record.
setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
printf 'status: draft\n' >> work/specs/spec-001.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
sed '$d' work/specs/spec-001.md > work/specs/spec-001.md.tmp \
  && mv work/specs/spec-001.md.tmp work/specs/spec-001.md
printf 'status: approved\n' >> work/specs/spec-001.md
commit_all
check "a quoted status swap in a body is not a transition" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish
