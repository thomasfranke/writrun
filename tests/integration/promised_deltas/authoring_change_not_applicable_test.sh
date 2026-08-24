#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
commit_all
check "no spec reaching implemented means deltas do not apply" 0 "not applicable" \
  -- bash "$CI_SCRIPTS/check_promised_deltas.sh" main...HEAD

finish
