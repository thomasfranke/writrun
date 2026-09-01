#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A spec that reached the authority branch already promising an entry
# without the index is out of this gate's reach — the spec's own edge case
# says history is not re-judged here. The range that matters is the
# completion pull request, which touches the spec only to flip its status:
# refusing it would advise a fix that costs one edit at exactly the moment
# it costs an amendment under a finished branch, which is the opposite of
# why this check exists.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0038 task-0028 implemented \
  technical/decisions/tasks-and-specs/0059-the-pause-is-derived.md
commit_all

check "the omission the range inherited is left to the completion gate" 0 \
  "every mandatory companion is present" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
