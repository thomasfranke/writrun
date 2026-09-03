#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A project holding both `docs/tests/` and `tests/`. The documentation
# reading wins, because refusal requires that `docs/<first-segment>` not
# exist — and where it does, the promise is one a diff can keep.
setup
mkdir -p tests docs/tests
: > tests/keep.sh
: > docs/tests/keep.md
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "tests/how-we-test.md"
commit_all

check "the docs/ counterpart makes the promise keepable" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
