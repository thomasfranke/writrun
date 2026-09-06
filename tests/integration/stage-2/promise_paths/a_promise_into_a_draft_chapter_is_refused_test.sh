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

# And the closing advice matches the fault. The resolution trailer tells
# an author to write the path as the schema reads it — advice this author
# has already followed to the letter, which would send them hunting a
# typo that is not there. That is the failure this refusal was written to
# spare them, so the trailer is the draft one instead.
refute "the resolution advice is not printed for a path that resolves" \
  "Write it as the schema reads it" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

check "the advice given is about the rule, not the spelling" 1 \
  "never to the spelling" \
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

# A spec faulting both ways gets both trailers: the resolution advice is
# suppressed for the draft fault, never for a fault that earned it.
setup
mkdir -p docs/product/concepts tests/unit
: > tests/unit/keep.sh
printf '/// writrun:draft\n# Not a rule yet\n' > docs/product/concepts/drafted.md
task_file task-0030 ready spec-0040
spec_file spec-0040 task-0030 draft \
  "product/concepts/drafted.md" "tests/unit/keep.sh"
commit_all

check "a range faulting both ways still gets the resolution advice" 1 \
  "Write it as the schema reads it" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

check "and the draft advice beside it" 1 "never to the spelling" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
