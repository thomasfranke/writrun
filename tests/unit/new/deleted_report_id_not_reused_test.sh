#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# An id is never reused, and a deleted file is invisible to the directory
# scan — so the history is asked too, exactly as it is for a task. A
# recurrence is a new report, which only means anything if the number the
# first one held stays spent.
setup
bash "$NEW_SH" report "First sighting" >/dev/null 2>&1
commit_all
rm work/reports/report-0001-first-sighting.md
commit_all
bash "$NEW_SH" report "Second sighting" >/dev/null 2>&1
if [ -f work/reports/report-0002-second-sighting.md ]; then
  echo "ok    a deleted report's id is not reused"; pass=$((pass + 1))
else
  echo "FAIL  a deleted report's id is not reused"
  ls work/reports | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
