#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The authoring case itself, in miniature: a spec promises the dated
# decisions entry and not the index row that adding an entry implies. It
# passed approval and a whole implementation before the completion gate
# refused a finished branch. Here, where the spec enters, the fix is one
# edit.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md
commit_all

check "an entry promised without the index is refused" 1 "and not docs/technical/decisions/README.md" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD
check "and the spec is named" 1 "spec-0038 promises" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
