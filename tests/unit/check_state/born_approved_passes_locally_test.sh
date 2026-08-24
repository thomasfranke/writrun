#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Deliberately not judged locally: in a diff, the legitimate flip (recorded
# after a maintainer approved the PR) and self-approval look identical.
# CI's writrun check settles it against the PR's actual reviews.
setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 approved
commit_all
check "a spec born approved passes locally (CI judges the review)" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish
