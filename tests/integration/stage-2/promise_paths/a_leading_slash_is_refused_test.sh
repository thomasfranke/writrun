#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A leading slash makes the first segment empty, so condition one has
# nothing to compare and the path would pass on a suffix that reads as a
# documentation path. `check_deltas.sh` prefixes it into `docs//…`,
# which no diff can ever match — the late refusal this gate exists to
# move earlier.
setup
mkdir -p tests/unit
: > tests/unit/keep.sh
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "/tests/unit/"
commit_all

check "a leading slash is refused" 1 "a leading slash makes a path no diff can match" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# Including where nothing about the rest of the path is root-relative,
# which is the case that passed on its suffix alone.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "/product/concepts/report.md"
commit_all

check "and so is one whose suffix reads as a documentation path" 1 "a leading slash makes a path no diff can match" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "and is shown the reading it took" 1 "docs//product/concepts/report.md" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
