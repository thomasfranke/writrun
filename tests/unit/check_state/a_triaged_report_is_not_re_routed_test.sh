#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule J — a report's status is the route triage took, not a lifecycle.
# Triage ran once; a second sighting is a second observation, with its own
# id and its own date (docs/product/concepts/report.md). The two forbidden
# moves are asserted separately, because they fail for different reasons
# and a reader of the message has to be told which one they made.

# Recording rides any change, so a report may arrive already terminal —
# the ordinary case, and never a skipped gate.
setup
report_file report-0001 fixed "" 2026-08-23T00:00:00Z
commit_all
check "a report born terminal is recorded, not refused" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 declined "" 2026-08-23T00:00:00Z
commit_all
check "open -> an end is triage, and is what the field is for" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 declined "" 2026-08-23T00:00:00Z
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 open
commit_all
check "an ended report never returns to open" 1 "returns declined -> open" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 fixed "" 2026-08-23T00:00:00Z
commit_all
check "and never moves from one end to another" 1 "one end to another" \
  -- bash "$CHECK_STATE" main...HEAD

finish
