#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The middle view, and the reason it exists. Collapsing a failed mirror
# listing to `local` would throw away a correct open-pull-request answer
# and make the note claim less than the run knew, so the two halves fail
# apart: the file lists still decide the number, the mirrors are named as
# unanswered, and the mint exits 0 as a best-effort read always does.
setup
stub_forge
forge_pr 7 added work/reports/report-0012-theirs.md
forge_mirrors_unreadable

check "a refused mirror listing narrows the view" 0 \
  "the mirrors went unanswered" \
  -- bash "$NEW_SH" report "Mine"
if [ -f work/reports/report-0013-mine.md ]; then
  echo "ok    and the three views that answered still decide"
  pass=$((pass + 1))
else
  echo "FAIL  and the three views that answered still decide"
  ls work/reports | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# The narrow note is not the full one. Pinning this is the point of the
# case: without it a later refactor collapses three views back into two
# and every assertion above still passes.
refute "and never claims the mirrors answered" "every mirror" \
  -- bash "$NEW_SH" report "Mine again"

finish
