#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# "A promise under `docs/`'s own top level shall pass" — including the
# form that carries no slash at all. Its whole text is a file name, not
# a first segment, so reading it as one would compare it against the
# repository's root *files* and refuse `README.md`, which every
# repository has and no `docs/README.md` need shadow.
setup
: > README.md                     # the root file whose name it shares
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "README.md"
commit_all

check "a top-level docs promise sharing a root file's name passes" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# And one whose name matches nothing at the root, for the plain case.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "about.md"
commit_all

check "and so does one the root does not name" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# The root *directory* collision is still condition one's, unchanged: a
# first segment only exists where there is a slash to find it.
setup
mkdir -p tests/unit
: > tests/unit/keep.sh
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "tests/unit/harness.md"
commit_all

check "a root directory as the first segment is still refused" 1 "docs/tests/unit/harness.md" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
