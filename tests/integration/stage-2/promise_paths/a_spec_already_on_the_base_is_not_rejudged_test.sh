#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# History is not re-judged: the same boundary the companions check
# draws. A spec that reached the base branch carrying an offending path
# is the completion gate's, or a run that merely flips `approved` to
# `implemented` would be refused with a message insisting the cheap fix
# is still available when it is not.
setup
mkdir -p tests/unit
: > tests/unit/keep.sh
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "tests/unit/whatever/"
commit_all
git checkout -q main
git merge -q --ff-only feature
git checkout -qb later

# The range touches a different spec entirely.
task_file task-0029 ready spec-0039
spec_file spec-0039 task-0029 draft "product/concepts/fine.md"
commit_all

check "an offending spec the range does not touch is ignored" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
