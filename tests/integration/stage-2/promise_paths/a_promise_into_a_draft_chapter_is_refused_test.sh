#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A chapter that declares itself a draft is not a rule, so promising to
# change one is a promise about a chapter no task was allowed to be born
# from. The path resolves perfectly — the file is right there — which is
# why the refusal says what is actually wrong instead of "cannot
# resolve", and why the author is not sent hunting a typo.
setup
mkdir -p docs/product/concepts
printf '/// writrun:draft\n# Not a rule yet\n' > docs/product/concepts/drafted.md
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "product/concepts/drafted.md"
commit_all

check "a promise into a draft chapter is refused" 1 "declares itself a draft" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# The same chapter once it is a rule: nothing about the promise changed,
# only what the chapter says about itself.
setup
mkdir -p docs/product/concepts
printf '# A real rule\n' > docs/product/concepts/drafted.md
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "product/concepts/drafted.md"
commit_all

check "and passes once the chapter is a rule" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# A promise of a doc that does not exist yet is still legitimate, and
# still not a draft — the two refusals must not be conflated.
setup
task_file task-0029 ready spec-0039
spec_file spec-0039 task-0029 draft "product/concepts/not-written-yet.md"
commit_all

check "a doc that does not exist yet is not a draft chapter" 0 \
  "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
