#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The one label this pass declares and never writes. `writrun:submitted`
# is applied by the report form and by the kit's routing instruction, and
# **a form referencing a label the repository does not have drops it
# silently** — the marker would appear to work everywhere except in the
# repository the submissions actually arrive at. So it is declared here,
# where the machinery already talks to its own label set
# (docs/technical/decisions/github-issues/0076-a-marker-is-not-a-gate.md).
setup_forge
added_task task-001 "Add search"
check "the open pass reconciles as before" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and declares the marker the form will apply" \
  "POST repos/o/r/labels -f name=writrun:submitted"
forge_not_told "without ever applying it to a mirror" \
  "labels[]=writrun:submitted"

# Unconditional, because the open event is not the one that must not find
# the label missing — every pass declares it, the merged close included.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-001 "Caught up at merge"
check "the merged close reconciles as before" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and declares the marker too" \
  "POST repos/o/r/labels -f name=writrun:submitted"

finish
