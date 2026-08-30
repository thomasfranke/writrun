#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The first half of the amend cycle (Pipeline: special flows): returning an
# approved spec to draft, with its body edited, crosses no gate.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 draft
commit_all
check "approved -> draft (an amendment) is legal" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish
