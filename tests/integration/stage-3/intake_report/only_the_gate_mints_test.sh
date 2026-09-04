#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

# Arrival creates nothing and the label is the assent — so a label that
# is not the gate mints nothing, and a title already carrying a mirror
# tag says the issue is some file's mirror already, whose writer is
# another workflow. The second refusal is also what makes a re-delivered
# label event a no-op: the first run's retitle wrote the tag it exits on
# (docs/product/stage-3-github-issues/intake.md).
setup_intake

export LABEL_NAME="bug"
check "a label that is not the gate mints nothing" 0 \
  "not the gate" \
  -- bash "$INTAKE" o/r 9
check "and the queue on the authority branch is untouched" 0 "README.md" \
  -- authority ls-tree --name-only main:work/reports
refute "no report file appeared" "report-0001" \
  -- authority ls-tree --name-only main:work/reports
forge_not_told "and the forge was asked to change nothing" "PATCH"

export LABEL_NAME="writrun:report"
export ISSUE_TITLE="[REPORT-0002] Already a mirror"
check "a title already tagged as a report's mirror is another workflow's" 0 \
  "already carries a mirror tag" \
  -- bash "$INTAKE" o/r 9
refute "and it mints nothing either" "report-" \
  -- authority ls-tree --name-only main:work/reports
forge_not_told "nor retitles anything" "PATCH"

export ISSUE_TITLE="[TASK-0007] A task's mirror"
check "a task mirror's title is refused the same way" 0 \
  "already carries a mirror tag" \
  -- bash "$INTAKE" o/r 9
forge_not_told "with the forge asked for nothing" "PATCH"

finish
