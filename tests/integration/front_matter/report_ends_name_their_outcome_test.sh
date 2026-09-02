#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Two of the four ends say where the outcome went, and the field that says
# it is part of the judgement rather than a decoration on it: `tracked`
# means a task now carries the work, `authored` means a rule was written
# (docs/product/concepts/report.md#statuses--the-route-not-a-lifecycle).
# Unpaired, `status: tracked` with `task_ref: []` was canonical — a report
# permanently claiming work nothing carries, and a mirror closed
# `completed` on the strength of it.
setup

report_file report-0001 tracked "" 2026-08-22T01:00:00Z
check "tracked with no task is refused" 1 \
  "task_ref is what names it" \
  -- bash "$CHECK_FRONT_MATTER"

report_file report-0001 tracked task-0001 2026-08-22T01:00:00Z
check "and passes once a task names the outcome" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

report_file report-0001 authored "" 2026-08-22T01:00:00Z
check "authored with no doc is refused" 1 \
  "doc_ref is what names it" \
  -- bash "$CHECK_FRONT_MATTER"

mkdir -p docs/product
: > docs/product/concepts.md
report_file report-0001 authored "" 2026-08-22T01:00:00Z product/concepts.md
check "and passes once the rule it names is there" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# The other two ends name their outcome where this checker cannot follow —
# `fixed` in the git history, `declined` in the body — so neither field is
# required of them. The asymmetry is the concept's, not an omission.
report_file report-0001 fixed "" 2026-08-22T01:00:00Z
check "fixed names the git history, and nothing here" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

report_file report-0001 declined "" 2026-08-22T01:00:00Z
check "declined names the body, and nothing here" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
