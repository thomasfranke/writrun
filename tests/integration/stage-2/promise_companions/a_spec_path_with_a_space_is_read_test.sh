#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Word splitting turns one path holding a space into two paths that exist
# nowhere, each skipped by the `-f` test — the incomplete promise dropped
# in silence and the gate passing. A gate reads every line it was given or
# refuses; it never drops one.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md
mv "work/specs/spec-0038.md" "work/specs/spec 0038.md"
commit_all

check "the promise is read through a path holding a space" 1 "spec-0038 promises" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
