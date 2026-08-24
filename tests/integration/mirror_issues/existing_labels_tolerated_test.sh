#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# The labels already exist on the forge (HTTP 422 on create) — that is
# the steady state, not a failure, and the reconciliation proceeds.
setup_forge
touch "$FAKE_GH_DIR/labels_422"
added_task task-001 "Add search"
check "existing labels do not abort the run" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the issue is still created" \
  "POST repos/o/r/issues -f title=task-001 — Add search"

finish
