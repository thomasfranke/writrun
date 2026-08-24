#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The patterns anchor to the branch's start — unanchored, a branch such
# as `spec/012-split-task-4` would resolve to task-4 instead of spec-012
# and move the wrong mirror.
setup_forge
export PR_HEAD_REF="spec/012-split-task-4"
base_spec spec-012 task-009
forge_issue 40 open "writrun:task,status:ready" "task-009 — Split"
forge_issue 41 open "writrun:task,status:ready" "task-004 — Bystander"
check "the branch resolves through its spec" 0 \
  "task-009 → status:in-review (#7)" \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_told "the spec's task moves" \
  "PUT repos/o/r/issues/40/labels"
forge_not_told "the look-alike task does not" \
  "repos/o/r/issues/41"

finish
