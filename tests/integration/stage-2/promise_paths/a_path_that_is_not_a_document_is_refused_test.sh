#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Condition two, on its own: the first segment is no root entry, so the
# path is a documentation path by location — but a promise the doc-delta
# loop can use names a .md file or a folder written with a slash.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "product/concepts/report.txt"
commit_all

check "a non-.md, non-folder path is refused" 1 "a promise names a .md file or a folder" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "and is shown the reading it took" 1 "docs/product/concepts/report.txt" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# A folder promise of the same area is the legal form.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "product/concepts/"
commit_all

check "the trailing-slash folder form passes" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
