#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The flag's position is the whole of what it says — everything after it
# is the mint's, and a miss there fails the step rather than reporting a
# finding. A line built wrong therefore turns notices into red runs, so
# the two ways of building one wrong are refused rather than read.
setup_forge
base_task task-0008 ready ""
base_task task-0009 ready ""

check "a run naming no repository is a usage error, and says so" 3 \
  "usage: rederive_labels.sh" -- bash "$REDERIVE_LABELS"
check "--minted twice is refused, not silently half-read" 3 \
  "given twice" \
  -- bash "$REDERIVE_LABELS" o/r --minted task-0009 --minted task-0008
forge_untouched "and neither of them asked the forge anything"

finish
