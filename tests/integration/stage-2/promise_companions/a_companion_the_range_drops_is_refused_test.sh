#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The other side of not re-judging history: a pair is left alone only when
# *both* halves predate the range. An amendment that takes the index back
# out of a promise that carried it made the promise incomplete, and that is
# this range's doing however old the entry is.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md \
  technical/decisions/README.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md
commit_all

check "the promise the range broke is refused" 1 \
  "and not technical/decisions/README.md" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
