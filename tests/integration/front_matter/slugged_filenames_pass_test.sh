#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# <id>-<subject>.md is the shape the generator writes; the canonical
# check has to accept it, or nothing generated after the rule could
# merge. The id is still what identity is read from.
setup
task_file task-0004 pending spec-0001
spec_file spec-0001 task-0004 draft
mv work/tasks/task-0004.md work/tasks/task-0004-queue-file-names.md
mv work/specs/spec-0001.md work/specs/spec-0001-queue-file-names.md
check "a slugged queue file is canonical" 0 "all canonical" \
  -- bash "$CI_SCRIPTS/check_front_matter.sh"

finish
