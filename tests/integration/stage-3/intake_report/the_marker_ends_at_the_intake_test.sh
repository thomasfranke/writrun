#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

# The marker's end is the intake. Once the report is minted the issue is
# a mirror, and two labels claiming the same fact would start disagreeing
# the first time one of them was written by hand
# (docs/product/stage-3-github-issues/intake.md#submitted-and-not-yet-a-report).
setup_intake

export ISSUE_TITLE="A submission that deserves a file"
check "the gate's label still mints the report" 0 "recorded work/reports/report-0001" \
  -- bash "$INTAKE" o/r 9
forge_told "the mirror is labelled as recorded" "labels[]=status:open"
forge_told "and the marker is removed in the same step" \
  "issues/9/labels/writrun:submitted"

# The marker is not the gate, and nothing about applying it moves. A
# label event that is not `writrun:report` mints nothing — including this
# one, which is the label an agent or the form applies on the way in.
setup_intake
export LABEL_NAME="writrun:submitted"
export ISSUE_TITLE="An observation, freshly submitted"
check "the marker mints nothing" 0 "not the gate" -- bash "$INTAKE" o/r 9
refute "no report file appeared" "report-0001" \
  -- authority ls-tree --name-only main:work/reports
forge_not_told "and the forge was asked to change nothing" "PATCH"
forge_not_told "not even to take the marker off again" \
  "labels/writrun:submitted"

finish
