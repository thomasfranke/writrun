#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Most rows have no `previous_filename`, and the tuple carries "-" for
# them rather than the empty string. A tab is IFS whitespace, so an empty
# middle field collapses on read and every field after it shifts one
# left — the patch landing where the path goes, and the row parsing as
# nothing at all. The placeholder is the whole defence, and it is asked
# for in the jq, so that is where it is pinned.
setup_forge
added_report report-0003 "The mirror shows backlog for ready tasks"
added_task task-0004 "Something else"

check "a diff of ordinary rows mirrors both files" 0 \
  "Created issue for report-0003" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the task beside it is read unshifted too" \
  "POST repos/o/r/issues -f title=[TASK-0004] Something else"
forge_told "and the file list asks for the previous name with a placeholder" \
  'previous_filename // "-"'

finish
