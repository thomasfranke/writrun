#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The failure this section is most exposed to: an empty section and an
# unasked question look identical, and the empty one reads as "nothing
# is waiting". The set lives on the forge and nowhere else, so a run that
# could not reach it says so instead of printing the heading
# (docs/technical/selection/visibility.md#a-submission-is-named-before-it-is-a-report).
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
stub_forge
forge_unavailable

check "a run that could not ask names the question it could not answer" 0 \
  "could not ask GitHub which observations are submitted" -- bash "$LIST_TASKS"
refute "and prints no heading with nothing under it" "waiting for a report" \
  -- bash "$LIST_TASKS"

# A forge that answers, with nothing to say, is the other case entirely:
# the question was asked and nothing is waiting, so neither the heading
# nor the note is billed to the run.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
stub_forge
refute "an answered question prints no heading" "waiting for a report" \
  -- bash "$LIST_TASKS"
refute "and no note either" "could not ask GitHub which observations" \
  -- bash "$LIST_TASKS"

finish
