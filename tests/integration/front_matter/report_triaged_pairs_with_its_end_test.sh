#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `triaged` and a terminal status are one fact written twice, so they are
# paired both ways — the shape blocked/blocked_reason already has. A date
# on an `open` report claims a judgement the status denies; a terminal
# report with no date is a judgement nothing can be ordered against, and
# ordering by these strings is what every line-based reader here does.
setup

report_file report-0001 open "" 2026-08-22T01:00:00Z
check "a date on an open report is refused" 1 \
  "only once triage has ended it" \
  -- bash "$CHECK_FRONT_MATTER"

report_file report-0001 tracked task-0001 null
check "and a terminal report with no date is refused too" 1 \
  "triaged is null" \
  -- bash "$CHECK_FRONT_MATTER"

report_file report-0001 declined "" 2026-08-22T01:00:00Z
check "declined names no task, and is still an end with a date" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
