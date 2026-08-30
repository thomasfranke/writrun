#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A draft is derivation still under review in the working session — its
# tasks are not public queue entries yet. Nothing is even asked of the
# forge until ready_for_review.
setup_forge
export PR_DRAFT=true
added_task task-001 "Not public yet"
check "an open draft defers the mirror" 0 "Draft PR" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_untouched "the forge is not consulted at all"

finish
