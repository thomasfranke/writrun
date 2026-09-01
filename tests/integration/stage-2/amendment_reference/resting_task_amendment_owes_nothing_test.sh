#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The pre-implementation amendment flow — the doc read against the spec
# before any code is written — is the cheap one, and this gate must leave
# it exactly as it was. Nothing is in flight, so nothing is suspended.
setup
task_file task-0007 ready spec-0009
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0009 task-0007 draft
commit_all
stub_forge
export PR_BODY=$'## What\nThe doc moved; the spec follows.'
check "amending a resting task's spec owes no reference" 0 "no task in flight" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9
forge_untouched "and the forge is never asked"

finish
