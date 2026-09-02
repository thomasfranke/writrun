#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The case that rules existence out as the test. A spec legitimately
# promises the doc its own change creates, so at spec entry the promised
# file is precisely what is not there yet.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  "product/concepts/not-written-yet.md" \
  "technical/decisions/pull-requests/0099-new.md"
commit_all

check "a doc the change will create passes" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
