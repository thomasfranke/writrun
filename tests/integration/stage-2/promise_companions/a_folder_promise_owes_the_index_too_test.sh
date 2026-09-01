#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A trailing `/` is how the delta contract promises everything beneath a
# folder, so promising the dated log's subfolder promises the entry that
# will land in it — and owes the index row exactly as naming the file
# would. A pair that read concrete paths alone would pass this and leave
# the index to surface at the completion gate as undeclared, which is the
# expensive failure this check exists to prevent.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft \
  technical/decisions/tasks-and-specs/
commit_all

check "the folder that will hold the entry owes the index" 1 \
  "and not technical/decisions/README.md" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish
