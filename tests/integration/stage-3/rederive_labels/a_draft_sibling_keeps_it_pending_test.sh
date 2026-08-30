#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# `spec_ref` is 0..N. One approved spec does not make a task ready when a
# sibling is still draft — "ready for development" is every spec, not the
# one this merge happened to carry.
setup_forge
base_task task-0005 backlog "spec-0003, spec-0004"
base_spec spec-0003 task-0005 approved
base_spec spec-0004 task-0005 draft
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] Half approved"
check "a draft sibling keeps the task pending" 0 "task-0005 → status:backlog" \
  -- bash "$REDERIVE_LABELS" o/r work/specs/spec-0003.md
forge_told "the mirror stays backlog" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:backlog"

finish
