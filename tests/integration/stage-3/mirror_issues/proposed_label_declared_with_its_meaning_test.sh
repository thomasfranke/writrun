#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A label carries its description into every project that adopts this,
# and this script declares exactly the ones it still writes.
# `status:backlog` and `status:ready` are the projection's, declared
# where they are written (rederive_labels.sh) — one declared here and
# never worn is one more thing to keep in sync for nothing.
setup_forge
added_task task-001 "Add search"
check "the labels are declared at open" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "proposed is declared, and says it is not in the queue" \
  "-f name=status:proposed -f color=ededed -f description=A pull request proposes this task; it is not in the queue yet"
forge_not_told "and the queue's own labels are not declared here" \
  "-f name=status:backlog"

finish
