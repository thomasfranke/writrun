#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The edited-under-approval detection reads the front matter at both ends
# of the range, so a body edit that happens to add a quoted `status:`
# line cannot exempt the spec from the review requirement — that would be
# a route around the very check.
setup
stub_gh 0
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'status: draft\n' >> work/specs/spec-001.md
commit_all
check "a quoted status line does not hide an edit under approval" 1 "no status move" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_recorded_approvals.sh" main...HEAD o/r 1

finish
