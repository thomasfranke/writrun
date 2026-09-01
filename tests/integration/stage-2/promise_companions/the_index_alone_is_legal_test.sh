#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The implication runs one way. Appending a row to the chronology without
# adding an entry is a legitimate change — a correction, a re-link — and
# the pair table must not read as a requirement in both directions.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft technical/decisions/README.md
commit_all

check "the index promised alone owes no entry" 0 "every mandatory companion is present" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
