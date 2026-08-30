#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A body edit quoting `status: implemented` does not implement the spec:
# its promises are not checked against this diff — a change that would
# otherwise fail MISSING on a contract nobody invoked.
setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft product/chapter.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'status: implemented\n' >> work/specs/spec-001.md
commit_all
check "a quoted implemented line invokes no contract" 0 "not applicable" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promised_deltas.sh" main...HEAD

finish
