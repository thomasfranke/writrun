#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Condition two, on its own: the first segment is no root entry, so the
# path is a documentation path by location. What is left to refuse is a
# folder written without the trailing slash `check_deltas.sh` reads —
# the comparison would be against file paths and would never match.
#
# The extension is deliberately not the test any more. A document is not
# a file format, and `check_deltas.sh` has always read `docs/` whole, so
# refusing a non-Markdown promise here left such a file unpromisable at
# this gate and UNDECLARED at the completion gate — neither touchable nor
# declarable (report-0041, decision 0075).
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "product/concepts"
mkdir -p docs/product/concepts
commit_all

check "a folder written without its slash is refused" 1 "a folder promise is written with a trailing slash" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "and is shown the reading it took" 1 "docs/product/concepts" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# The same area with the slash is the legal folder form.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "product/concepts/"
commit_all

check "the trailing-slash folder form passes" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# A path that is not Markdown resolves like any other document.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "product/screens/first-run.excalidraw"
commit_all

check "a drawing is a document" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# Shape, never existence: the drawing above was never created, and the
# promise still passed. That is the rule 0065 established and this change
# leaves alone — a spec legitimately promises what its own change writes.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "technical/payloads/push.json"
commit_all

check "and a payload shape is one too, unwritten" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# Condition one is untouched, and it is what the extension test was
# standing in for: a repository-root path is refused by the segment that
# names it, whatever it ends in. The segment is read off the tree, so the
# fixture has to hold the root entry for the question to be asked at all.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "tests/harness.sh"
mkdir -p tests
: > tests/harness.sh
commit_all

check "a repository-root path is still refused" 1 "is a repository-root entry" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
