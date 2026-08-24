#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The shape the generator writes is the shape the contract names — a
# queue of generated files passes as-is.
setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
check "a canonical queue passes" 0 "all canonical" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
