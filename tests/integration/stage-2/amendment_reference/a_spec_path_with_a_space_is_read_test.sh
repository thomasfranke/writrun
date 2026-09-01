#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Word splitting turns one path holding a space into two paths that exist
# nowhere, each skipped by the `-f` test — the amendment dropped in
# silence and the gate passing. A gate reads every line it was given or
# refuses; it never drops one.
setup
task_file task-0007 in-progress spec-0012 "" dana
spec_file spec-0012 task-0007 approved
mv "work/specs/spec-0012.md" "work/specs/spec 0012.md"
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0012 task-0007 draft
mv "work/specs/spec-0012.md" "work/specs/spec 0012.md"
commit_all
stub_forge
forge_open_pr 7 task/0007-thing "[TASK-0007][Feat] the work"
export PR_BODY=$'## What\nThe promise was wrong, so the spec goes back to draft.'

check "the amendment is seen through a path holding a space" 1 "rides #7" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9

finish
